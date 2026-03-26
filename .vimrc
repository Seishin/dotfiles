" =========================
" Appearance
" =========================
syntax on                   " Enable syntax highlighting
set termguicolors           " Enable 24-bit RGB colors
set number                  " Show line numbers
set relativenumber          " Show relative line numbers
set cursorline              " Highlight the current line
set showmatch               " Highlight matching brackets

" =========================
" Behavior
" =========================
set mouse=a                 " Enable mouse support
set clipboard=unnamedplus   " Link Vim clipboard to system clipboard
set ignorecase              " Case insensitive search...
set smartcase               " ...unless I use a capital letter
set splitright              " Vertical splits open to the right
set splitbelow              " Horizontal splits open below
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nocursorline

" =========================
" vim-plug setup
" =========================
call plug#begin('~/.local/share/nvim/plugged')

" Theme & Visuals
Plug 'joshdick/onedark.vim'      " Modern dark theme fallback
Plug 'itchyny/lightline.vim'     " Sleek status bar
Plug 'ryanoasis/vim-devicons'    " Icons (requires Nerd Font)
Plug 'lifepillar/vim-solarized8' " True-color Solarized theme

" Productivity
Plug 'preservim/nerdtree'        " File explorer
Plug 'junegunn/fzf.vim'          " Fuzzy finder
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocomplete (IntelliSense)

call plug#end()

" =========================
" Theme configuration & Auto-switch
" =========================
" Function to read macOS theme and apply it
function! SyncMacTheme()
    " macOS returns 'Dark' if dark mode is on, otherwise it fails/returns empty
    let l:is_dark = system('defaults read -g AppleInterfaceStyle 2>/dev/null')
    
    if l:is_dark =~? 'Dark'
        set background=dark
    else
        set background=light
    endif
    
    " Apply the theme
    colorscheme solarized8
endfunction

" Run once on startup
call SyncMacTheme()

" Automatically re-check the theme whenever Vim regains focus
augroup MacThemeAutoSwitch
    autocmd!
    autocmd FocusGained * call SyncMacTheme()
augroup END

" Keybinds (from your original config)
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>

augroup auto_create_dir
  autocmd!
  autocmd BufWritePre * if !isdirectory(expand('<afile>:p:h')) | call mkdir(expand('<afile>:p:h'), 'p') | endif
augroup END
