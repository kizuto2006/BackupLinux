# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the Limine boot loader.
  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = true; #Bật SecureBoot cho Limine
  boot.loader.timeout = 5;                    # giây chờ ở menu
  boot.loader.limine.maxGenerations = 10;     # giữ tối đa 10 bản trong menu, đỡ đầy ESP
  boot.loader.limine.style = {
    wallpapers = [ ./boot-wallpaper.jpg ];
    wallpaperStyle = "stretched";

    # Ẩn tiêu đề trên đầu, giống CachyOS
    interface.branding = "";

    # Bảng màu Catppuccin Mocha giống CachyOS
    graphicalTerminal = {
      palette = "1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
      brightPalette = "585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
      foreground = "cdd6f4";
      brightForeground = "cdd6f4";
      background = "ffffffff";        # trong suốt hoàn toàn, để lộ ảnh nền
      brightBackground = "ffffffff";
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [ fcitx5-bamboo ];
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "bamboo";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "bamboo";
        GroupOrder."0" = "Default";
      };
    };
  };

  # Để Edge (Chromium) chạy bằng Wayland và nhận bộ gõ
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."kizuto" = {
    isNormalUser = true;
    description = "Kizuto";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    alacritty 
    kdePackages.dolphin 
    fastfetch 
    sbctl
    microsoft-edge
    feishin
    jellyfin-desktop
    vscode-fhs
    discord
    gh 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  #Git lfs
  programs.git = {
    enable = true;
    lfs.enable = true;    # bật Git LFS nếu cần
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
  #fish cùng starship
  programs.starship.enable = true;
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    nixcon = "nano /etc/nixos/configuration.nix";
  };
  #file manager: thunar cùng extension
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
  };
  services.gvfs.enable = true;    # SFTP, SMB, thùng rác
  services.tumbler.enable = true; # ảnh xem trước
  #an-anime-game-launcher = genshin
  programs.anime-game-launcher.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  programs.umbriel.enable = true;
  
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };
  
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };
  
  services.displayManager.noctalia-greeter.enable = true;

  services.tailscale.enable = true;

  # Driver NVIDIA (dòng này cần dù bạn dùng Wayland, để chặn nouveau)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;   # bắt buộc cho Wayland
    open = true;                 # RTX 2050 (Ampere) dùng được module kernel mở
    nvidiaSettings = false;      # công cụ GUI, chưa cần

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # tạo lệnh nvidia-offload
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  #Thêm swap vào phân vùng
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024;   # MiB, tương đương 8 GB
  }];
}
