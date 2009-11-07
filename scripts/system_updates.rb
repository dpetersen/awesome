#!/usr/bin/ruby

ignorepkg_string = `egrep ^IgnorePkg /etc/pacman.conf`
ignorepkg_string.gsub!(/IgnorePkg\s+=\s+/, "")

filter_ignored = ignorepkg_string.split.inject("") do |s, pkg|
  s << %{ | grep -v "^#{pkg}\s"}
end

packages = `pacman -Qu #{filter_ignored} | wc -l`
puts packages
