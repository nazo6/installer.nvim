function! installer#install(args)
  if empty(a:args[2])
    call v:lua.require("installer").install_all()
  endif
  call v:lua.require("installer").install(a:args[0], a:args[1])
endfunction

function! installer#uninstall(args)
  if empty(a:args[2])
    call v:lua.require("installer").uninstall_all()
  endif
  call v:lua.require("installer").uninstall(a:args[0], a:args[1])
endfunction

function! installer#update(args)
  if empty(a:args[2])
    call v:lua.require("installer").update_all()
  endif
  call v:lua.require("installer").update(a:args[0], a:args[1])
endfunction

function! installer#reinstall(args)
  if empty(a:args[2])
    call v:lua.require("installer").reinstall_all()
  endif
  call v:lua.require("installer").reinstall(a:args[0], a:args[1])
endfunction

" completions
function! installer#available_servers() abort
  return luaeval('require("installer").available_servers()')
endfunction

function! installer#installed_servers() abort
endfunction

function! installer#is_server_installed(lang) abort
  return luaeval('require("installer").is_server_installed("'.a:lang.'")')
endfunction

function! s:complete_available(args, line, pos) abort
  if empty(a:args[1])
    let a:res = luaeval('require("installer").status.categories()')
  else
    let a:res = luaeval('require("installer").categories_installed("'.a:args[1].'")')
  endif
  return join(a:res, "\n")
endfunction
function! s:complete_installed(arg, line, pos) abort
  if empty(a:args[1])
    let a:res = luaeval('require("installer").status.categories()')
  else
    let a:res = luaeval('require("installer").categories_installed("'.a:args[1].'")')
  endif
  return join(a:res, "\n")
endfunction

command! -nargs=* -complete=custom,s:complete_available Install :call installer#install('<args>')
command! -nargs=* -complete=custom,s:complete_installed Uninstall :call installer#uninstall('<args>')
command! -nargs=* -complete=custom,s:complete_installed Update :call installer#update('<args>')
command! -nargs=* -complete=custom,s:complete_installed Reinstall :call installer#reinstall('<args>')
