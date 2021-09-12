function! installer#install(category, name)
  call v:lua.require("installer").install(a:category, a:name)
endfunction

function! installer#uninstall(category, name)
  call v:lua.require("installer").uninstall(a:category, a:name)
endfunction

function! installer#update(category, name)
  call v:lua.require("installer").update(a:category, a:name)
endfunction

function! installer#reinstall(category, name)
  call v:lua.require("installer").reinstall(a:category, a:name)
endfunction

" completions
function! installer#available_servers() abort
  return luaeval('require("installer").available_servers()')
endfunction

function! installer#installed_servers() abort
  return luaeval('require("installer").installed_servers()')
endfunction

function! installer#is_server_installed(lang) abort
  return luaeval('require("installer").is_server_installed("'.a:lang.'")')
endfunction

function! s:complete_available(arg, line, pos) abort
  return join(installer#installed_servers(), "\n")
endfunction
function! s:complete_installed(arg, line, pos) abort
  return join(installer#available_servers(), "\n")
endfunction

command! -nargs=* -complete=custom,s:complete_available Install :call installer#install(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Uninstall :call installer#uninstall(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Update :call installer#uninstall_server(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Reinstall :call installer#reinstall_server(<f-args>)
