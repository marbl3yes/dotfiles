syntax on
set clipboard=unnamedplus
set number
set relativenumber
set title
set noswapfile
set hlsearch
set cursorline
:highlight Cursorline cterm=bold ctermbg=black
set ignorecase
set smartcase
set incsearch
set showmatch
set tabstop=4
set shiftwidth=4
set autoindent
set mouse=a
set smarttab
set softtabstop=4
colorscheme pablo

call plug#begin()

Plug 'preservim/nerdtree'
Plug 'tpope/vim-commentary' " For Commenting gcc & gc
Plug 'vim-airline/vim-airline' " Status bar
Plug 'ap/vim-css-color'
Plug 'neoclide/coc.nvim' " Auto Completion
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf.vim' " Fuzzy Finder
Plug 'junegunn/fzf'
Plug 'iamcco/markdown-preview.nvim'
Plug 'sheerun/vim-polyglot'
Plug 'jiangmiao/auto-pairs'
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'airblade/vim-gitgutter'

let g:dashboard_default_executive ='fzf'

set encoding=UTF-8

call plug#end()

" File browser
let g:netrw_banner=0
let g:netrw_liststyle=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_winsize=25
let g:netrw_keepdir=0
let g:netrw_localcopydircmd='cp -r'

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-l> :call CocActionAsync('jumpDefinition')<CR>
nnoremap <silent> <C-p> :Files<CR>

set termwinsize=15x0

nnoremap <F4> :bd<CR>
nnoremap <F6> :bo terminal<CR>

" Tabs
nnoremap <silent> <S-t> :enew<CR>
nnoremap <silent> <Tab> :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>

nmap <C-m> <Plug>MarkdownPreviewToggle

set completeopt-=preview " For No Previews

let g:NERDTreeShowHidden=1
let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

let g:coc_node_path='/home/sergio-pereira/.nvm/versions/node/v16.15.0/bin/node'

" --- Just Some Notes ---
" :PlugClean :PlugInstall :UpdateRemotePlugins
"
" :CocInstall coc-python
" :CocInstall coc-clangd
" :CocInstall coc-snippets
" :CocCommand snippets.edit... FOR EACH FILE TYPE

" Markdown
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_frontmatter=1
let g:vim_markdown_conceal=0
let g:vim_mardown_fenced_languages=['tsx=typescriptreact']

" air-line
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled=1

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

inoremap <silent><expr> <TAB>
	\ coc#pum#visible() ? coc#pum#next(1) :
	\ CheckBackspace() ? "\<TAB>" :
	\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() :
	\ "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

function CheckBackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction
