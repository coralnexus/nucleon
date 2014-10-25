
RSpec.shared_context "config" do

  #*****************************************************************************
  # Context test data

  let(:config_context_data) do {
      :context1 => {
        :greeting => "hello",
        :nestedkey => {
          :a => {
            :test1 => 'yes',
            :test2 => [ 'please' ]
          },
          :x => 'goodbye'
        },
        :other => "Something else",
        :array => [ 128 ]
      },
      :context2 => {
        :greeting  => "hello world",
        :something => "test",
        :nestedkey => {
          :a => {
            :test1 => [ 23, 55 ]
          },
          :b => 'oddball'
        },
        :array => [ 128, 1024 ]
      },
      :prefix1_context1 => {
        :greeting  => "how are you",
        :something => "test5"
      },
      :prefix2_context3 => {
        :thought => "hope this test passes"
      }
    }
  end

  let(:config_context_default_data) do {
      :greeting   => 'howdy',
      :array      => [ 4545, :hello ],
      :extra => 'this should not be set'
    }
  end

  let(:config_contexts1) { [ :context1, "context3" ] }
  let(:config_context_hierarchy1) { :prefix2 }

  let(:config_context_options1) do {
      :greeting => "hello",
      :nestedkey => {
        :a => {
          :test1 => 'yes',
          :test2 => [ 'please' ]
        },
        :x => 'goodbye'
      },
      :other => "Something else",
      :array => [ 128 ],
      :thought  => "hope this test passes"
    }
  end

  let(:config_flat_contexts1) { [ :context1, "context2" ] }

  let(:config_flat_context_options1) do {
      :greeting  => "hello world",
      :nestedkey => {
        :a => {
          :test1 => [ 23, 55 ],
          :test2 => [ 'please' ]
        },
        :x => 'goodbye',
        :b => 'oddball'
      },
      :other => "Something else",
      :array => [ 128, 1024 ],
      :something => "test"
    }
  end

  let(:config_contexts2) { [ "context1", :context2, :context3 ] }
  let(:config_context_hierarchy2) { [ :prefix1, "prefix2" ] }

  let(:config_context_options2) do {
      :greeting  => "how are you",
      :nestedkey => {
        :a => {
          :test1 => [ 23, 55 ],
          :test2 => [ 'please' ]
        },
        :b => 'oddball',
        :x => 'goodbye'
      },
      :other => "Something else",
      :array => [ 128, 1024 ],
      :something => "test5",
      :thought   => "hope this test passes"
    }
  end

  let(:config_contexts3) { :context1 }
  let(:config_context_hierarchy3) { [ :prefix1, "prefix2" ] }

  let(:config_context_options3) do {
      :greeting  => "how are you",
      :nestedkey => {
        :a => {
          :test1 => "yes",
          :test2 => [ 'please' ]
        },
        :x => 'goodbye'
      },
      :other => "Something else",
      :array => [ 128 ],
      :something => "test5"
    }
  end

  let(:config_flat_contexts2) { "context2" }

  let(:config_flat_context_options2) do {
      :greeting  => "hello world",
      :something => "test",
      :nestedkey => {
        :a => {
          :test1 => [ 23, 55 ]
        },
        :b => 'oddball'
      },
      :array => [ 128, 1024 ]
    }
  end


  before(:each) do
    Nucleon::Config.clear_options
    config_context_data.each do |context, options|
      Nucleon::Config.set_options(context, options)
    end
  end


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
  # Data hashes (symbolization and stingification)

  let(:config_mixed_hash) do {
      "stringkey" => true,
      :symbolkey  => true,
      "inner" => {
        :good => "almost",
        "bad" => "maybe sometimes"
      }
    }
  end

  let(:config_symbolized_hash) do {
      :stringkey => true,
      :symbolkey => true,
      :inner => {
        :good => "almost",
        :bad  => "maybe sometimes"
      }
    }
  end

  let(:config_stringified_hash) do {
      "stringkey" => true,
      "symbolkey" => true,
      "inner" => {
        "good" => "almost",
        "bad"  => "maybe sometimes"
      }
    }
  end

  #*****************************************************************************
  # Merge results (hash1 overrides context options)

  let(:config_hash_context1_force_basic_merge) do {
      :greeting => "hello",
      :thought  => "hope this test passes",
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
      :array => [ 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context1_force_deep_merge) do {
      :greeting => "hello",
      :thought  => "hope this test passes",
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ "please", "no" ]
        },
        :x => 'hello',
        :y => 'again',
        :z => 'im done now'
      },
      :other => [ 1, 2, 3, 4 ],
      :array => [ 4545, :hello, 128, 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context1_no_force_basic_merge) do {
      :greeting => "hello",
      :thought  => "hope this test passes",
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
      :array => [ 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context1_no_force_deep_merge) do {
      :greeting => "howdy",
      :thought  => "hope this test passes",
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'yes',
          :test2 => [ 'please', 'no' ]
        },
        :x => 'goodbye',
        :y => 'again',
        :z => 'im done now'
      },
      :other => "Something else",
      :array => [ 4545, :hello, 128, 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end


  let(:config_hash_context2_force_basic_merge) do {
      :greeting  => "how are you",
      :something => "test5",
      :thought   => "hope this test passes",
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
      :array => [ 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context2_force_deep_merge) do {
      :greeting  => "how are you",
      :something => "test5",
      :thought   => "hope this test passes",
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => ["please", "no"]
        },
        :x => 'hello',
        :b => "oddball",
        :y => 'again',
        :z => 'im done now'
      },
      :other => [ 1, 2, 3, 4 ],
      :array => [ 4545, :hello, 128, 1024, 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context2_no_force_basic_merge) do {
      :greeting  => "how are you",
      :something => "test5",
      :thought   => "hope this test passes",
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
      :array => [ 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context2_no_force_deep_merge) do {
      :greeting  => "howdy",
      :something => "test5",
      :thought   => "hope this test passes",
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => [ 23, 55 ],
          :test2 => [ "please", "no" ]
        },
        :x => 'goodbye',
        :b => "oddball",
        :y => 'again',
        :z => 'im done now'
      },
      :other => "Something else",
      :array => [ 4545, :hello, 128, 1024, 3, 6, 9 ],
      :extra => 'this should not be set'
    }
  end


  let(:config_hash_context3_force_basic_merge) do {
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
      :array => [ 3, 6, 9 ],
      :greeting  => "how are you",
      :something => "test5",
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context3_force_deep_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'oh',
          :test2 => [ 'please', 'no' ]
        },
        :x => 'hello',
        :y => 'again',
        :z => 'im done now'
      },
      :other => [ 1, 2, 3, 4 ],
      :array => [ 4545, :hello, 128, 3, 6, 9 ],
      :greeting  => "how are you",
      :something => "test5",
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context3_no_force_basic_merge) do {
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
      :array => [ 3, 6, 9 ],
      :greeting  => "how are you",
      :something => "test5",
      :extra => 'this should not be set'
    }
  end

  let(:config_hash_context3_no_force_deep_merge) do {
      :testkey => 'testval',
      :nestedkey => {
        :a => {
          :test1 => 'yes',
          :test2 => [ 'please', 'no' ]
        },
        :x => 'goodbye',
        :y => 'again',
        :z => 'im done now'
      },
      :other => "Something else",
      :array => [ 4545, :hello, 128, 3, 6, 9 ],
      :greeting  => "howdy",
      :something => "test5",
      :extra => 'this should not be set'
    }
  end


  #*****************************************************************************
  # Merge results (hash2 overrides hash1)

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