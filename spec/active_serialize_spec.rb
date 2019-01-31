RSpec.describe ActiveSerialize do
  before { User.create([ { name: 'aa' }, { name: 'bb' } ]) }
  after { ActiveSerialize.configs['User'] = nil }

  describe '#to_h' do
    context 'normally' do
      it { expect(User.first.to_h.keys).to eq %w[ name created_at updated_at ] }
      it { expect(User.first.to_h(rmv: [:created_at], add: :love).keys).to eq %w[ name updated_at love ] }
    end

    context 'when removing some attributes' do
      before { User.active_serialize_rmv *%i[ created_at updated_at ] }
      it { expect(User.first.to_h.keys).to eq %w[ name ] }
    end

    context 'when adding some keys' do
      before { User.active_serialize_add :love }
      it { expect(User.first.to_h.keys).to eq %w[ name created_at updated_at love ] }
      it { expect(User.first.to_h['love']).to eq 'Ruby' }

      context 'and a recursive attribute' do
        before { User.active_serialize_add :books, recursive: true }
        before { User.first.books.create(name: 'Rails') }

        it { expect(User.first.to_h.keys).to eq %w[ name created_at updated_at love books ] }
        it { expect(User.first.to_h['books']).to eq [{ 'name' => 'Rails' }] }
        it { expect(User.last.to_h['books']).to eq [ ] }
      end

      context 'and a named(map) addition key' do
        before { User.active_serialize_add :method_a, named: :method_b }
        it { expect(User.first.to_h.keys).to eq %w[ name created_at updated_at love method_b ] }
      end
    end
  end

  describe 'Class Method .to_ha' do
    before { User.active_serialize_rmv *%i[ created_at updated_at ] }
    it { expect(User.all.to_ha).to eq [ { "name" => "aa" }, { "name" => "bb" } ] }
  end
end
