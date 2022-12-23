require('orgmode').setup_ts_grammar()
require('orgmode').setup({
  org_agenda_files = {'~/Dropbox/org/*'},
  org_default_notes_file = '~/Dropbox/org/refile.org',
  win_split_mode = 'float',
  mappings = {
    org = {
      org_return = '<C-CR>',
      org_timestamp_up = '<A-UP>',
      org_timestamp_down = '<A-Down>'
    }
  }
})