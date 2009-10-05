Dir.glob("inactive_record/**") do |filename|
  require filename
end