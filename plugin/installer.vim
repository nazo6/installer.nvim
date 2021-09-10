" API

function! installer#install_server(lang)
  call v:lua.require("installer").install_server(a:lang)
endfunction

function! installer#uninstall_server(lang)
  call v:lua.require("installer").uninstall_server(a:lang)
endfunction

function! installer#reinstall_server(lang)
  call v:lua.require("installer").reinstall_server(a:lang)
endfunction

function! installer#available_servers() abort
  return luaeval('require("installer").available_servers()')
endfunction

function! installer#installed_servers() abort
  return luaeval('require("installer").installed_servers()')
endfunction

function! installer#is_server_installed(lang) abort
  return luaeval('require("installer").is_server_installed("'.a:lang.'")')
endfunction

" Interface

command! -nargs=1 -complete=custom,s:complete_install Install :call installer#install_server('<args>')
command! -nargs=1 -complete=custom,s:complete_uninstall Uninstall :call installer#uninstall_server('<args>')
command! -nargs=1 -complete=custom,s:complete_uninstall Update :call installer#uninstall_server('<args>')
command! -nargs=1 -complete=custom,s:complete_uninstall Reinstall :call installer#reinstall_server('<args>')

function! s:complete_install(arg, line, pos) abort
  return join(installer#available_servers(), "\n")
endfunction
function! s:complete_uninstall(arg, line, pos) abort
  return join(installer#installed_servers(), "\n")
endfunction
