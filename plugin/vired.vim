if exists('g:loaded_vired')
	finish
endif

let g:loaded_vired = 1

fun! s:OpenVired(path)
	let l:target = empty(a:path) ? '.' : a:path
	let l:dir = fnamemodify(l:target, ':p')

	enew
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	setlocal filetype=vired

	let b:vired_dir = l:dir

	let l:output = b:vired_dir . " - " . system('ls -lah --group-directories-first ' . shellescape(b:vired_dir))
	call setline(1, split(l:output, "\n"))

	syntax clear
	syntax match ViredDirectory /^d.*/
	syntax match ViredHeader /^total .*/
	syntax match ViredHeader /\/.*/
	syntax match ViredSymlink /.*->.*/

	highlight default link ViredDirectory Directory
	highlight default link ViredHeader Comment
	highlight default link ViredSymlink String

	nnoremap <buffer> <CR> :call <SID>Vired_OpenFile()<CR>
	nnoremap <buffer> -	:call <SID>Vired_UpperDir()<CR>
endfun

fun! s:Vired_OpenFile()
	let l:line = getline('.')

	if l:line =~# '^total' || empty(trim(l:line))
		return
	endif

	let l:parts = split(l:line)
	if empty(l:parts)
		return
	endif

	let l:filename = join(l:parts[8:], ' ')
	if empty(l:filename)
		return
	endif

	if l:filename ==# '.'
		return
	elseif l:filename ==# '..'
		call s:Vired_UpperDir()
		return
	endif

	let l:target = b:vired_dir . l:filename

	if isdirectory(l:target)
		call s:OpenVired(l:target)
	else
		let l:filepath = fnamemodify(l:target, ':.')
		wincmd p
		execute 'edit ' . fnameescape(l:filepath)
	endif
endfun

fun! s:Vired_UpperDir()
	let l:parent = fnamemodify(b:vired_dir . '../', ':p')
	call s:OpenVired(l:parent)
endfun

command! -nargs=? -complete=dir Vired call s:OpenVired(<q-args>)
nnoremap <leader>d :Vired<CR>
