function acer-fans
    set ec /sys/kernel/debug/ec/ec0/io
    
    set fan1 (sudo od -An -j92 -N2 -tu1 $ec | string split -n ' ')
    set fan2 (sudo od -An -j106 -N2 -tu1 $ec | string split -n ' ')
    
    set rpm1 (math "$fan1[1] * 256 + $fan1[2]")
    set rpm2 (math "$fan2[1] * 256 + $fan2[2]")
    
    echo "Fan 1: $rpm1 RPM"
    echo "Fan 2: $rpm2 RPM"
end
