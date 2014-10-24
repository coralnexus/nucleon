
RSpec.shared_context "config" do

  #*****************************************************************************
  # Source hashes

  let(:config_hash1) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'no' ]
        },
        :x => 'hello',
        :y => 'again',
        :z => 'im done now'
      },
      :other => [ 1, 2, 3, 4 ],
      :array => [ 3, 6, 9 ]
    }
  end

  let(:config_hash2) do {
      :testkey1 => 'testval1',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'yes' ],
          :test3 => true
        },
        :z => 'whew'
      },
      :other => 56,
      :array => [ 12 ]
    }
  end

  #*****************************************************************************
  # Merge results

  let(:config_hash_no_force_basic_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'yes' ],
          :test3 => true
        },
        :z => 'whew'
      },
      :other => 56,
      :array => [ 12 ],
      :testkey1 => 'testval1'
    }
  end

  let(:config_hash_force_basic_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'yes' ],
          :test3 => true
        },
        :z => 'whew'
      },
      :other => 56,
      :array => [ 12 ],
      :testkey1 => 'testval1'
    }
  end

  let(:config_hash_no_force_deep_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'no', 'yes' ],
          :test3 => true
        },
        :x => 'hello',
        :y => 'again',
        :z => 'im done now'
      },
      :other => [ 1, 2, 3, 4 ],
      :array => [ 3, 6, 9, 12 ],
      :testkey1 => 'testval1'
    }
  end

  let(:config_hash_force_deep_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'no', 'yes' ],
          :test3 => true
        },
        :x => 'hello',
        :y => 'again',
        :z => 'whew'
      },
      :other => 56,
      :array => [ 3, 6, 9, 12 ],
      :testkey1 => 'testval1'
    }
  end
end