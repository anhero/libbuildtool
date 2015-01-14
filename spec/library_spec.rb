require 'ostruct'
require_relative '../classes/library.rb'

$build_options = OpenStruct.new()
BaseLibrary = Libraries::BaseLibrary

class MockStep < LBT::Step
	def run
		return
	end
	def should_run
		return true
	end
end

class NoRunMock < LBT::Step
	def run
		return
	end
	def should_run
		return false
	end
end

describe BaseLibrary do
	it "Is initialized with its named arguments associated with the OpenStruct" do
		mylib = BaseLibrary.new(foo: "bar", baz: 1)
		expect(mylib.foo).to eq("bar")
		expect(mylib.baz).to eq(1)
	end

	# Next four tests are testing that the old behaviour is gone.
	it "Takes steps when name finishes with 'er'" do
		mylib = BaseLibrary.new()
		step = MockStep.new
		mylib.mocker = step
		expect(mylib.mocker).to eq(step)
	end

	it "Takes steps when name not finishing with 'er'" do
		mylib = BaseLibrary.new()
		step = MockStep.new
		mylib.mock = step
		expect(mylib.mock).to eq(step)
	end

	it "Takes values when name finishes with 'er'" do
		mylib = BaseLibrary.new()
		mylib.barrier = 1
		expect(mylib.barrier).to eq(1)
	end

	it "Takes values when name not finishing with 'er'" do
		mylib = BaseLibrary.new()
		mylib.barry = 1
		expect(mylib.barry).to eq(1)
	end

	# Then, those tests test the validity of the insertion.
	it "Adding step with a name finishing in 'er' adds it to the @steps collection." do
		mylib = BaseLibrary.new()
		step = MockStep.new
		mylib.mocker = step
		expect(mylib.mocker).to eq(step)
		expect(mylib.all_steps.count).to eq(1)
		expect(mylib.all_steps.first[:instance]).to eq(step)
	end

	it "Adding step with a name NOT finishing in 'er' adds it to the @steps collection." do
		mylib = BaseLibrary.new()
		step = MockStep.new
		mylib.mock = step
		expect(mylib.mock).to eq(step)
		expect(mylib.all_steps.count).to eq(1)
		expect(mylib.all_steps.first[:instance]).to eq(step)
	end

	it "Adding a value with a name finishing in 'er' adds it in the OpenStruct, not in @steps." do
		mylib = BaseLibrary.new()
		mylib.barrier = 1
		expect(mylib.barrier).to eq(1)
		expect(mylib.all_steps.count).to eq(0)
	end

	it "Adding a value with a name NOT finishing in 'er' adds it in the OpenStruct, not in @steps." do
		mylib = BaseLibrary.new()
		mylib.barry = 1
		expect(mylib.barry).to eq(1)
		expect(mylib.all_steps.count).to eq(0)
	end
end

