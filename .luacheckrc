std = 'lua51'
globals = { 'vim' }

stds.busted = {
  read_globals = {
    'describe',
    'it',
    'before_each',
    'after_each',
    'pending',
    'setup',
    'teardown',
    'finally',
  },
}

files['tests/'] = {
  std = '+busted',
  -- luassert extends the `assert` global with fields (are.same, is_true, ...)
  -- that luacheck cannot see, so accessing-undefined-field warnings on it
  -- are expected here.
  ignore = { '143' },
}
