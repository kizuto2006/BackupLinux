function fish_user_key_bindings
    # ============================================
    # 1. Gỡ bỏ các keybind cũ để tránh xung đột
    # ============================================
    # Gỡ các phím Ctrl đang dùng token
    bind -e ctrl-left
    bind -e ctrl-right
    bind -e ctrl-backspace
    bind -e ctrl-delete
    
    # Gỡ các phím Alt đang dùng word
    bind -e alt-b
    bind -e alt-f
    bind -e alt-d
    bind -e alt-backspace
    bind -e alt-delete
    bind -e alt-t
    
    # ============================================
    # 2. CHUYỂN CTRL → WORD (thay vì token)
    # ============================================
    # Di chuyển
    bind ctrl-left  backward-word      # Ctrl+←: lùi 1 word
    bind ctrl-right forward-word       # Ctrl+→: tới 1 word
    
    # Xóa
    bind ctrl-backspace backward-kill-word   # Ctrl+Backspace: xóa lùi 1 word
    bind ctrl-delete   kill-word             # Ctrl+Delete: xóa tới 1 word
    
    # ============================================
    # 3. CHUYỂN ALT → LINE (thay vì word)
    # ============================================
    # Di chuyển
    bind alt-b backward-line        # Alt+B: lùi 1 dòng (lên trên)
    bind alt-f forward-line         # Alt+F: tới 1 dòng (xuống dưới)
    # Hoặc nếu bạn muốn di chuyển đến đầu/cuối dòng:
    # bind alt-b beginning-of-line
    # bind alt-f end-of-line
    
    # Xóa
    bind alt-backspace backward-kill-line   # Alt+Backspace: xóa lùi đến đầu dòng
    bind alt-delete   kill-line             # Alt+Delete: xóa tới cuối dòng
    
    # Chuyển đổi (transpose)
    bind alt-t transpose-lines       # Alt+T: đổi chỗ 2 dòng liền kề
    
    # Di chuyển nhanh (tùy chọn thêm)
    bind alt-d kill-line             # Alt+D: xóa từ vị trí hiện tại đến cuối dòng
    
    # ============================================
    # 4. GIỮ NGUYÊN các phím di chuyển cơ bản
    # ============================================
    # Các phím này không thay đổi để giữ thói quen
    # bind left   backward-char
    # bind right  forward-char
    # bind home   beginning-of-line
    # bind end    end-of-line
    
    # ============================================
    # 5. GIỮ NGUYÊN keybind của autopair (quan trọng!)
    # ============================================
    # (Không ghi đè lên bind của autopair)
end
