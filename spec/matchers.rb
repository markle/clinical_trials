RSpec::Matchers.define :be_longer_than do |expected|
  match do |actual|
    (actual||"").length > expected
  end
end

RSpec::Matchers.define :be_shorter_than do |expected|
  match do |actual|
    (actual||"").length < expected
  end
end

RSpec::Matchers.define :contain_the_string do |expected|
  match do |actual|
    !!((actual||"") =~ /#{expected}/i)
  end
end
