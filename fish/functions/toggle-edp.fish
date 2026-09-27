function toggle-edp
    set file ~/.config/umbriel/cfg/display.toml
    if grep -A3 '\[output\."eDP-1"\]' $file | grep -q 'enabled = false'
        sed -i '/\[output\."eDP-1"\]/,/^\[/{s/enabled = false/enabled = true/}' $file
    else
        sed -i '/\[output\."eDP-1"\]/,/^\[/{s/enabled = true/enabled = false/}' $file
    end
end
