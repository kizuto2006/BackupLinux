#!/usr/bin/env bash

# Dừng script ngay khi có lỗi.
set -Eeuo pipefail

# Tên cấu hình nằm trong nixosConfigurations của flake.nix.
# Có thể đổi tạm bằng:
# NIXOS_CONFIG_NAME=ten-khac ./install-nixos.sh
CONFIG_NAME="${NIXOS_CONFIG_NAME:-nixos}"

# Xác định thư mục chứa chính script.
# Nhờ vậy repo đặt ở đâu cũng chạy được.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

REPO_DIR="$SCRIPT_DIR"
FLAKE_DIR="$REPO_DIR/nixos"
SYSTEM_HARDWARE_CONFIG="/etc/nixos/hardware-configuration.nix"
REPO_HARDWARE_CONFIG="$FLAKE_DIR/hosts/acer-a715/hardware-configuration.nix"

# Bật flakes kể cả khi hệ thống hiện tại chưa khai báo vĩnh viễn.
export NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG
}experimental-features = nix-command flakes"
# Mặc định là ~/.config.
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Nơi lưu config cũ trước khi thay bằng symlink.
TIMESTAMP="$(date +'%Y%m%d-%H%M%S')"
BACKUP_DIR="$CONFIG_HOME/.dotfiles-backup/$TIMESTAMP"

CURRENT_STEP="khởi tạo"
BACKUP_CREATED=false

info() {
    printf '\033[1;34m==>\033[0m %s\n' "$*"
}

success() {
    printf '\033[1;32m✓\033[0m %s\n' "$*"
}

warning() {
    printf '\033[1;33m!\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31mLỖI:\033[0m %s\n' "$*" >&2
    exit 1
}

# Hàm này tự chạy khi một lệnh trong script gặp lỗi.
on_error() {
    local exit_code=$?

    printf '\n\033[1;31mCÀI ĐẶT THẤT BẠI\033[0m\n' >&2
    printf 'Bước đang thực hiện: %s\n' "$CURRENT_STEP" >&2
    printf 'Dòng script: %s\n' "${BASH_LINENO[0]:-không xác định}" >&2
    printf 'Lệnh gây lỗi: %s\n' "${BASH_COMMAND:-không xác định}" >&2
    printf 'Mã thoát: %s\n' "$exit_code" >&2

    if [[ "$BACKUP_CREATED" == true ]]; then
        printf 'Config cũ đã được giữ tại:\n%s\n' "$BACKUP_DIR" >&2
    fi

    printf 'Script đã dừng và không chạy các bước còn lại.\n' >&2
    exit "$exit_code"
}

trap on_error ERR

require_command() {
    command -v "$1" >/dev/null 2>&1 \
        || die "Không tìm thấy lệnh '$1'."
}

check_repository() {
    CURRENT_STEP="kiểm tra cấu trúc repository"

    [[ -f "$FLAKE_DIR/flake.nix" ]] \
        || die "Không tìm thấy $FLAKE_DIR/flake.nix"

    [[ -f "$FLAKE_DIR/flake.lock" ]] \
        || die "Không tìm thấy $FLAKE_DIR/flake.lock"

    local folder

    for folder in fish niri zed fastfetch; do
        [[ -d "$REPO_DIR/$folder" ]] \
            || die "Không tìm thấy thư mục $REPO_DIR/$folder"
    done

    success "Cấu trúc repository hợp lệ"
}

sync_hardware_config() {
    CURRENT_STEP="đồng bộ hardware configuration"

    [[ -f "$SYSTEM_HARDWARE_CONFIG" ]] \
        || die "Không tìm thấy $SYSTEM_HARDWARE_CONFIG. Hãy chạy nixos-generate-config trước."

    mkdir -p "$(dirname -- "$REPO_HARDWARE_CONFIG")"

    info "Đang lấy hardware configuration từ hệ thống hiện tại:"
    printf '    %s\n' "$SYSTEM_HARDWARE_CONFIG"
    printf ' -> %s\n' "$REPO_HARDWARE_CONFIG"

    sudo cp -- "$SYSTEM_HARDWARE_CONFIG" "$REPO_HARDWARE_CONFIG"
    sudo chown "$(id -u):$(id -g)" "$REPO_HARDWARE_CONFIG"

    cmp -s "$SYSTEM_HARDWARE_CONFIG" "$REPO_HARDWARE_CONFIG" \
        || die "Hardware configuration sau khi copy không khớp."

    success "Đã đồng bộ hardware configuration của máy hiện tại"
}

check_git_status() {
    CURRENT_STEP="kiểm tra trạng thái Git"

    if git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch="$(git -C "$REPO_DIR" branch --show-current || true)"

        info "Nhánh hiện tại: ${branch:-detached HEAD}"

        if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
            warning "Repo có thay đổi chưa commit."
            warning "Script vẫn tiếp tục và sử dụng nội dung hiện tại."
        fi
    else
        warning "$REPO_DIR không phải Git repository."
        warning "Script vẫn tiếp tục."
    fi
}

check_flake() {
    CURRENT_STEP="kiểm tra flake NixOS"

    info "Đang kiểm tra flake..."

    nix flake check "path:$FLAKE_DIR" --no-build

    success "Flake hợp lệ"
}

rebuild_nixos() {
    CURRENT_STEP="build và switch hệ thống NixOS"

    info "Đang build và switch:"
    printf '    %s#%s\n' "$FLAKE_DIR" "$CONFIG_NAME"

    sudo env NIX_CONFIG="$NIX_CONFIG" \
	nixos-rebuild switch \
	--flake "path:$FLAKE_DIR#$CONFIG_NAME"

    success "NixOS đã build và switch thành công"
}

backup_and_link() {
    local name="$1"
    local source="$REPO_DIR/$name"
    local target="$CONFIG_HOME/$name"

    CURRENT_STEP="triển khai dotfile $name"

    # Nếu symlink đã trỏ đúng vào repo thì không làm lại.
    if [[ -L "$target" ]]; then
        local current_target
        local expected_target

        current_target="$(readlink -f -- "$target" || true)"
        expected_target="$(readlink -f -- "$source")"

        if [[ "$current_target" == "$expected_target" ]]; then
            success "$target đã trỏ đúng; bỏ qua"
            return
        fi
    fi

    # Nếu config cũ đang tồn tại thì chuyển vào thư mục backup.
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        BACKUP_CREATED=true

        info "Backup:"
        printf '    %s\n' "$target"
        printf ' -> %s/%s\n' "$BACKUP_DIR" "$name"

        mv -- "$target" "$BACKUP_DIR/$name"
    fi

    # Tạo symlink từ ~/.config sang thư mục trong repo.
    ln -s -- "$source" "$target"

    success "Đã liên kết $target -> $source"
}

deploy_dotfiles() {
    CURRENT_STEP="chuẩn bị thư mục config"

    mkdir -p "$CONFIG_HOME"

    local folder

    for folder in fish niri zed fastfetch; do
        backup_and_link "$folder"
    done
}

validate_dotfiles() {
    CURRENT_STEP="kiểm tra dotfiles sau khi cài"

    if command -v fish >/dev/null 2>&1; then
        fish -n "$CONFIG_HOME/fish/config.fish"
        success "Cú pháp Fish hợp lệ"
    else
        warning "Không tìm thấy Fish; bỏ qua kiểm tra config Fish."
    fi

    if command -v niri >/dev/null 2>&1; then
        niri validate
        success "Cấu hình Niri hợp lệ"
    else
        warning "Không tìm thấy Niri; bỏ qua niri validate."
    fi

    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch \
            --config "$CONFIG_HOME/fastfetch/config.jsonc" \
            >/dev/null

        success "Cấu hình Fastfetch chạy được"
    else
        warning "Không tìm thấy Fastfetch; bỏ qua kiểm tra."
    fi

    if [[ -f "$CONFIG_HOME/zed/settings.json" ||
          -f "$CONFIG_HOME/zed/settings.jsonc" ]]; then
        success "Đã tìm thấy cấu hình Zed"
    else
        warning "Không thấy settings.json hoặc settings.jsonc trong config Zed."
    fi
}

main() {
    printf '\n'
    printf '\033[1mBackupLinux - NixOS rebuild và dotfiles installer\033[0m\n'
    printf '\n'

    # Kiểm tra các lệnh tối thiểu cần thiết.
    for command_name in \
        nix \
        sudo \
        nixos-rebuild \
        git \
        ln \
        mv \
        readlink
    do
        require_command "$command_name"
    done

    check_repository
    sync_hardware_config
    check_git_status
    check_flake
    rebuild_nixos
    deploy_dotfiles
    validate_dotfiles

    printf '\n'
    printf '\033[1;32mHOÀN TẤT\033[0m\n'
    printf '\n'

    printf 'NixOS đã được build từ:\n'
    printf '  path:%s#%s\n' "$FLAKE_DIR" "$CONFIG_NAME"

    printf '\nDotfiles đã được liên kết:\n'
    printf '  %s/fish\n' "$CONFIG_HOME"
    printf '  %s/niri\n' "$CONFIG_HOME"
    printf '  %s/zed\n' "$CONFIG_HOME"
    printf '  %s/fastfetch\n' "$CONFIG_HOME"

    if [[ "$BACKUP_CREATED" == true ]]; then
        printf '\nConfig cũ được backup tại:\n'
        printf '  %s\n' "$BACKUP_DIR"
    else
        printf '\nKhông có config cũ nào cần backup.\n'
    fi

    printf '\nScript đã kết thúc.\n'
}

main "$@"
