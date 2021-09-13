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

function! s:complete_available(args, line, pos) abort
  let args = split(a:line, " ", 1)
  if len(args) <= 2
    let res = luaeval('require("installer/status/available").get_categories()')
  else
    let res = luaeval('require("installer/status/available").get_category_modules("'.args[1].'")')
  endif
  return join(keys(res), "\n")
endfunction
function! s:complete_installed(args, line, pos) abort
  let args = split(a:line, " ", 1)
  if len(args) <= 2
    let res = luaeval('require("installer/status/installed").get_categories()')
  else
    let res = luaeval('require("installer/status/installed").get_category_modules("'.args[1].'")')
  endif
  return join(keys(res), "\n")
endfunction

command! -nargs=* -complete=custom,s:complete_available Install :call installer#install(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Uninstall :call installer#uninstall(<f-args>)
command! -nargs=* -complete=custom,s:complete_installed Reinstall :call installer#reinstall(<f-args>)
