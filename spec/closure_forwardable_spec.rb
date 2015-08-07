describe ClosureForwardable do
  let(:wrapper) do
    Class.new do
      extend ClosureForwardable
    end
  end

  let(:receiver_class) do
    Struct.new(:id) do
      def echo(*args)
        yield self if block_given?
        [id, *args]
      end
    end
  end

  let(:receiver) { receiver_class.new('receiver') }
  let(:alternate) { receiver_class.new('alternate') }

  describe '.debug' do
    let(:module_file_regexp) do
      path = File.expand_path('../../lib/closure_forwardable.rb', __FILE__)
      Regexp.escape(path)
    end

    let(:collection) do
      wrapper.closure_delegate(echo: receiver)
      wrapper.new
    end

    # A custom error we use to distinguish errors raised by us from actual
    # code problems
    class MyError < StandardError; end

    after { ClosureForwardable.debug = nil }

    it 'filters the error backtrace by default' do
      ClosureForwardable.debug = nil

      expect { collection.echo { fail MyError, 'Error!' } }
        .to raise_error do |error|
          expect(error).to be_a(MyError)
          expect(error.backtrace).to_not include(/\A#{module_file_regexp}/)
        end
    end

    it 'when enabled doesn\'t filter the error backtrace' do
      ClosureForwardable.debug = true

      expect { collection.echo { fail MyError, 'Error!' } }
        .to raise_error { |error|
          expect(error).to be_a(MyError)
          expect(error.backtrace).to include(/\A#{module_file_regexp}/)
        }
    end
  end

  describe '#closure_delegate' do
    it 'allows to specify methods' do
      wrapper.closure_delegate(echo: receiver)

      expect(wrapper.instance_methods(false)).to eql [:echo]
    end

    it 'allows to forward multiple methods to a single receiver' do
      wrapper.closure_delegate([:echo, :id] => receiver)

      expect(wrapper.instance_methods(false).sort)
        .to eql [:echo, :id]
    end

    it 'allows methods to be forwarded to different receivers' do
      wrapper.closure_delegate(echo: receiver, id: alternate)

      expect(wrapper.instance_methods(false).sort).to eql [:echo, :id]

      collection = wrapper.new

      expect(collection.echo(:hello)).to eql ['receiver', :hello]
      expect(collection.id).to eql 'alternate'
    end
  end

  describe '#def_closure_delegators' do
    it 'allows to forward multiple methods to the same receiver' do
      wrapper.def_closure_delegators(receiver, :echo, :id)

      expect(wrapper.instance_methods(false).sort).to eql [:echo, :id]
    end

    it 'does not forward __send__' do
      wrapper.def_closure_delegators(receiver, :__send__)
      wrapper.def_closure_delegators(receiver, '__send__')

      expect(wrapper.instance_methods(false)).to be_empty
    end

    it 'does not forward __id__' do
      wrapper.def_closure_delegators(receiver, :__id__)
      wrapper.def_closure_delegators(receiver, '__id__')

      expect(wrapper.instance_methods(false)).to be_empty
    end
  end

  describe '#def_closure_delegator' do
    it 'creates forwarder methods' do
      wrapper.def_closure_delegator(receiver, :id)

      expect(wrapper.new.id).to eql 'receiver'
    end

    it 'uses the method_alias to set a custom name' do
      wrapper.def_closure_delegator(receiver, :id, :hello)

      expect(wrapper.instance_methods(false)).to eql [:hello]
      expect(wrapper.new.hello).to eql 'receiver'
    end

    it 'allows string and symbols equally' do
      wrapper.def_closure_delegator(receiver, 'id', 'str_str')
      wrapper.def_closure_delegator(receiver, 'id', :str_sym)
      wrapper.def_closure_delegator(receiver, :id, 'sym_str')
      wrapper.def_closure_delegator(receiver, :id, :sym_sym)

      expect(wrapper.new.str_str).to eql 'receiver'
      expect(wrapper.new.str_sym).to eql 'receiver'
      expect(wrapper.new.sym_str).to eql 'receiver'
      expect(wrapper.new.sym_sym).to eql 'receiver'
    end

    it 'forwards the passed block' do
      wrapper.def_closure_delegator(receiver, :echo)

      expect { |b| wrapper.new.echo(&b) }.to yield_control
    end
  end
end
