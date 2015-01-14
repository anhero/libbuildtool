require_relative '../classes/arraystruct.rb'

describe ArrayStruct do
	it "Is initialized with now members with new()" do
		myas = ArrayStruct.new()
		count = myas.each_pair.count
		expect(count).to eq(0)
	end

	it "Is initialized with now members with the members passed to new()" do
		myas = ArrayStruct.new(foo: 1, bar: 2, baz: "three")
		count = myas.each_pair.count
		expect(count).to eq(3)

		expect(myas.foo).to eq([1])
		expect(myas.bar).to eq([2])
		expect(myas.baz).to eq(["three"])
	end

	it "Gives an array for non-array assigned to its properties (=)." do
		myas = ArrayStruct.new()
		myas.foo = "bar"
		expect(myas.foo).to eq(["bar"])

		myas = ArrayStruct.new()
		myas.foo = 1
		expect(myas.foo).to eq([1])
	end

	it "Unpacks an array into its array property when assigned." do
		myas = ArrayStruct.new()
		myas.foo = ["bar", "baz"]
		expect(myas.foo).to eq(["bar", "baz"])

		myas = ArrayStruct.new()
		myas.foo = [1, 2]
		expect(myas.foo).to eq([1, 2])
	end
	it "Does not unpack an array on new()." do
		myas = ArrayStruct.new(foo: ["bar", "baz"])
		expect(myas.foo).to eq([["bar", "baz"]])

		myas = ArrayStruct.new(foo: [1,2])
		expect(myas.foo).to eq([[1, 2]])
	end

	it "Initializes its array property on first append (<<)" do
		myas = ArrayStruct.new()
		myas.foo << "bar"
		expect(myas.foo).to eq(["bar"])

		myas = ArrayStruct.new()
		myas.foo << 1
		expect(myas.foo).to eq([1])
	end

	it "Does not unpack arrays on first append (<<)" do
		myas = ArrayStruct.new()
		myas.foo << [ "bar", "baz" ]
		expect(myas.foo).to eq([["bar", "baz"]])

		myas = ArrayStruct.new()
		myas.foo << [ 1, 2 ]
		expect(myas.foo).to eq([[1, 2]])
	end

	it "Appends values properly to an existing property." do
		myas = ArrayStruct.new()
		myas.foo = [1, 2, 3]
		myas.foo << 4
		expect(myas.foo).to eq([1,2,3,4])

		myas = ArrayStruct.new(foo: [1,2,3])
		myas.foo << 4
		expect(myas.foo).to eq([[1,2,3],4])
	end

	it "Multiple assignments to the same property works the same way." do
		myas = ArrayStruct.new()
		myas.foo = "bar"
		expect(myas.foo).to eq(["bar"])
		myas.foo = "bar"
		expect(myas.foo).to eq(["bar"])
		# Thrice just to be damn sure.
		myas.foo = "bar"
		expect(myas.foo).to eq(["bar"])
	end
end

ArrayStructElement = ArrayStruct::ArrayStructElement

describe ArrayStructElement do
	it "Initializes as an empty array, new() without arguments." do
		myase = ArrayStructElement.new()
		expect(myase).to eq([])
	end
	it "Initializes by unpacking the passed array to new(arr) as its own array." do
		myase = ArrayStructElement.new([1, 2, 3])
		expect(myase).to eq([1, 2, 3])
	end
	it "Initializes by using the passed first element as the first element to its own array." do
		myase = ArrayStructElement.new(1)
		expect(myase).to eq([1])

		myase = ArrayStructElement.new("foo")
		expect(myase).to eq(["foo"])
	end

	describe "joins and to_s"  do
		before do
			@myase = ArrayStructElement.new(["a", "b", "c"])
		end
		it "Joins strings with spaces on .to_s and implicit .to_s" do
			expect(@myase.to_s).to eq("a b c")
			expect("#{@myase}").to eq("a b c")
		end
		it "Uses the arguemnt to to_s as it would with join()" do
			expect(@myase.to_s(":")).to eq("a:b:c")
			expect(@myase.to_s("XX")).to eq("aXXbXXc")
			expect(@myase.to_s("")).to eq("abc")
		end

	end

	# TODO : Write more tests if needed, but those methods are not overridden anyway...
	describe "Test correctness of Array behaviour." do
		before do
			@myase = ArrayStructElement.new([1,2,3,4])
		end

		it ".<<" do
			@myase << 1
			expect(@myase).to eq([1,2,3,4,1])
		end
		it ".count" do
			expect(@myase.count).to eq(4)
		end
	end
end
