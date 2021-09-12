function! installer#install(arg1, ...)
  let arg2 = get(a:, 1, 0)
  let arg3 = get(a:, 2, 0)
  if empty(arg2)
    call v:lua.require("installer").install_all()
    return
  endif
  if !empty(arg3)
    echoerr "Too many args"
    return
  endif
  call v:lua.require("installer").install(a:arg1, arg2)
endfunction

function! installer#uninstall(arg1, ...)
  let arg2 = get(a:, 1, 0)
  let arg3 = get(a:, 2, 0)
  if empty(arg2)
    call v:lua.require("installer").uninstall_all()
    return
  endif
  if !empty(arg3)
    echoerr "Too many args"
    return
  endif
  call v:lua.require("installer").uninstall(a:arg1, arg2)
endfunction

function! installer#reinstall(arg1, ...)
  let arg2 = get(a:, 1, 0)
  let arg3 = get(a:, 2, 0)
  if empty(arg2)
    call v:lua.require("installer").reinstall_all()
    return
  endif
  if !empty(arg3)
    echoerr "Too many args"
    return
  endif
  call v:lua.require("installer").reinstall(a:arg1, arg2)
endfunction
function! installer#update(arg1, ...)
  let arg2 = get(a:, 1, 0)
  let arg3 = get(a:, 2, 0)
  if empty(arg2)
    call v:lua.require("installer").update_all()
    return
  endif
  if !empty(arg3)
    echoerr "Too many args"
    return
  endif
  call v:lua.require("installer").update(a:arg1, arg2)
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

command! -nargs=* -complete=custom,s:complete_available Install :call installer#install(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Uninstall :call installer#uninstall(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Update :call installer#update(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Reinstall :call installer#reinstall(<f-args>)
