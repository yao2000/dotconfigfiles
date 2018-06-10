set nocompatible

" Inspired by http://vim.spf13.com, but replace bundle with Vim-Plug and remove lots of less-used stuff
" Keep everything in a single file; Easy to read/review
" The only dependency is Vim-Plug;
"
" Usage:
" macOS/Linux:
"   cp .vimrc ~/.vimrc
"   curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Windows (PowerShell):
"   cp .vimrc ~/_vimrc
"   md ~\vimfiles\autoload
"   $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"   (New-Object Net.WebClient).DownloadFile(
"     $uri,
"     $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
"       "~\vimfiles\autoload\plug.vim"
"     )
"   )


" Identify platform {

  silent function! MACOS()
    return has('macunix')
  endfunction
  silent function! MACOS_GUI()
    return has('gui_macvim')
  endfunction
  silent function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
  endfunction
  silent function! WINDOWS()
    return  (has('win32') || has('win64'))
  endfunction
  silent function! WINDOWS_GUI()
     return (has('gui_win32') || has('gui_win64'))
  endfunction
  silent function! GUI()
    return has('gui_running')
  endfunction

" }


" Use Vim-Plug to manage plugins {
" - Avoid using standard Vim directory names like 'plugin'

  if WINDOWS()
    call plug#begin('~/vimfiles/plugged')
  else
    call plug#begin('~/.vim/plugged')
  endif

  Plug 'godlygeek/tabular'
  Plug 'plasticboy/vim-markdown'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tmhedberg/matchit'
  Plug 'scrooloose/nerdtree'
  Plug 'vim-scripts/AutoComplPop'
  Plug 'altercation/vim-colors-solarized'
  Plug 'sukima/xmledit', { 'for': 'xml' }
  Plug 'easymotion/vim-easymotion'
  Plug 'mbbill/undotree'
  Plug 'haya14busa/incsearch.vim'
  if version>=740
    Plug 'skywind3000/asyncrun.vim'
  endif
  if version>=720
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'tpope/vim-fugitive'
  endif

  " Initialize plugin system
  call plug#end()

" }


" General {

  set mouse=a
  if &term=~ '^screen'
    "tmux knows the extended mouse mode
    set ttymouse=xterm2
  else
    set ttymouse=xterm
  end
  set mousehide

  syntax on
  set t_Co=256
  set number
  set hlsearch
  set ignorecase
  set smartcase
  "set incsearch
  set history=256     " Number of things to remember in history
  set autowrite       " Writes on make/shell commands
  set autoread        " Autoread files changed outside vim
  set hidden          " Do not prompt when leaving unsaved buffer
  set timeoutlen=1500  "Time to wait after ESC or <leader>
  set tags=./tags;$HOME

  set encoding=utf8
  set termencoding=utf8
  set fileencoding=utf8

  if has("gui_running")
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
  endif

  " Windows specific setting, in both CMD.exe and gVim
  if WINDOWS()
    set fileencodings=ucs-bom,utf8,chinese,cp936
  endif

  set backspace=indent,eol,start " more powerful backspacing
  set ruler
  "set cursorline
  set wildmode=longest,list " At command line, complete longest common string, then list alternatives.
  set modeline
  set modelines=5

  if has('statusline')
    set laststatus=2
  endif

  if has('wildmenu')
    set wildmenu
  endif

" }


" Key (re)mapping {

  " The default leader and localleader are both '\'
  let mapleader = ','
  "let maplocalleader = '_'

  " Wrapped lines goes down/up to next row, rather than next line in file.
  noremap j gj
  noremap k gk

  " JSON
  nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
  let g:vim_json_syntax_conceal = 0

" }


" Background & theme {

  colorscheme solarized
  let g:airline_theme='solarized'
  set bg=light

  function! ToggleBackground()
    let s:thebackground = &background
    if s:thebackground == "dark"
      set bg=light
      let g:airline_solarized_bg='light'
    else
      set bg=dark
      let g:airline_solarized_bg='dark'
    endif
  endfunction
  noremap <leader>bg :call ToggleBackground()<CR>

  if !has("gui_running")
    "call ToggleBackground()
  endif

" }


" Line number toggle {

  function! ToggleLineNumber()
    let &l:number = 1-&l:number
  endfunction
  noremap <leader>nu :call ToggleLineNumber()<CR>

" }


" Formatting {

  set autoindent
  set nowrap
  set textwidth=0  " Don't wrap lines by default
  set shiftwidth=4                " Use indents of 4 spaces
  set expandtab                   " Tabs are spaces, not tabs
  set tabstop=4                   " An indentation every four columns
  set softtabstop=4               " Let backspace delete indent
  set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
  "set splitright                  " Puts new vsplit windows to the right of the current
  "set splitbelow                  " Puts new split windows to the bottom of the current

  if GUI()
    set guioptions-=T  " Remove the toolbar
  endif

  if WINDOWS_GUI()
    set guifont=Consolas:h11:cANSI:qDRAFT
  endif

  if has("autocmd")
    :autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4 autoindent
    :autocmd FileType c,cpp setlocal tabstop=4 expandtab shiftwidth=2 softtabstop=2 cindent
    :autocmd FileType md,markdown setlocal expandtab shiftwidth=2 softtabstop=4 tabstop=4 autoindent
  endif

" }


" Restore cursor to file position in previous editing session {
" Ref: http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
  set viminfo='10,\"100,:20,%,n~/.viminfo

  function! ResCur()
    if line("'\"") <= line("$")
      normal! g`"
      return 1
    endif
  endfunction

  if has("folding")
    function! UnfoldCur()
      if !&foldenable
        return
      endif
      let cl = line(".")
      if cl <= 1
        return
      endif
      let cf  = foldlevel(cl)
      let uf  = foldlevel(cl - 1)
      let min = (cf > uf ? uf : cf)
      if min
        execute "normal!" min . "zo"
        return 1
      endif
    endfunction
  endif

  augroup resCur
    autocmd!
    if has("folding")
      autocmd BufWinEnter * if ResCur() | call UnfoldCur() | endif
    else
      autocmd BufWinEnter * call ReCur()
    endif
  augroup END
" }End restore cursor position


" incsearch.vim {

  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

" }


" undotree {

  nnoremap <leader>u :UndotreeToggle<CR>
  " If undotree is opened, it is likely one wants to interact with it.
  let g:undotree_SetFocusWhenToggle=1
  if has('persistent_undo')
    set undodir='~/.undodir/'
    set undofile
  endif

" }


" vim-indent-guides {

  "noremap <leader>ig :IndentGuidesToggle
  "let g:indent_guides_enable_on_vim_startup = 1

" }


" AsyncRun {

  cnoreabbrev Arun AsyncRun
  cnoreabbrev Astop AsyncStop

" }
