; example 1 https://github.com/steelsojka/dotfiles2/tree/107f53d112ee5a575af4d3a34b5b528294e5580e/.vim/fnl/dotfiles
; example 2 https://github.com/Olical/dotfiles/tree/master/stowed/.config/nvim/fnl/dotfiles
; example 3 https://www.github.com/Javyre/etc/tree/master/nvim%2Ffnl%2Finit.fnl
; lua guid https://github.com/nanotee/nvim-lua-guide

; (fn begin-timer []
;   (vim.loop.hrtime))

; (fn end-timer [start msg?]
;   (let [end (vim.loop.hrtime)
;         msg (or msg? "Elapsed time: %f msecs")]
;   (print (string.format msg (/ (- end start) 1000000)))))

; (local init-timer (begin-timer))

(local u    (require :util))
(local a    (require :aniseed.core))
;https://github.com/norcalli/nvim.lua
(local nvim (require :aniseed.nvim))
(local str  (require :aniseed.string))
(local paq  (require :paq-nvim))

(require-macros :macros)

(local augroup u.augroup)

;; leader
;; leader is still set to \ but mapped to space
(set nvim.g.maplocalleader ",") ; map local leader to ,
(u.map :n  :<space>  :<leader>)
(u.map :x  :<space>  :<leader>)

;; Undo
(set nvim.o.undodir (.. (vim.fn.stdpath "cache") "/vim/undo/") )

 ;; for some reason (set nvim.o.undofile true) won't work
(nvim.ex.set :undofile)
(nvim.ex.set :list)
  ; folds
 (vim.cmd ":set foldmethod=syntax")
 (vim.cmd ":set foldlevel=99")

(a.assoc nvim.o
  :mouse          :a
  :title          true                    ;; Update window title
  :hidden         true                    ;; Allow to leave buffer without saving
  :showcmd        true                    ;; Show keys pressed in normal
  :lazyredraw     true
  :shortmess      :aAtcT                  ;; Get rid of annoying messagesc
  ; Tags
  :tags           ".tags,tags"            ;; Make tagefiles hidden
  :tagcase        :match                  ;; Match case when searching for tags
  ; Whitespace
  :listchars      "tab:→ ,trail:·,nbsp:·" ;; Show white space
  ; Indentation
  :tabstop        4                       ;; Shorter hard tabs
  :softtabstop    0                       ;; No spaces
  :smarttab       true
  :conceallevel   2
  :shiftwidth     4                       ;; Shorter shiftwidth
  :autoindent     true                    ;; Auto indent newline
  ; Searching
  :ignorecase     true
  :smartcase      true
  :incsearch      true                    ;; search while typing
  :hlsearch       true                    ;; highlight search
  ;
  :wildmenu       true                    ;; Autocompletion of commands
  :wildmode       "longest:full,full"
  :wildignorecase true
  ;
  :gdefault       true                    ;; global substitution by default (no need for /g flag)
  ; splits
  :splitbelow     true                    ;; open below instead of above
  :splitright     true                    ;; open right instead of left
  ;
  :termguicolors  true
  :clipboard      :unnamedplus            ;; xclip support
  :fillchars      "fold: ,diff: "
  :inccommand     :split
  :diffopt                                ;; smarter diff
  (.. (or nvim.o.diffopt "") ",indent-heuristic,algorithm:histogram")
  :wildmenu        true                   ;; Autocompletion of commands
  :wildmode        "longest:full,full"
  :wildignorecase  true
  :wildignore      "*.git/*,*.tags,tags,*.o,*.class,*.ccls-cache"
  :virtualedit     :block
  :completeopt "menuone,noselect")


; Capital Quick first letter of a word or a regain
; should eventually be replaced  with fennel
(vim.cmd "nmap <leader>t :set opfunc=dotvim#titlecase<CR>g@")
(vim.cmd "xmap <leader>t :<C-U>call dotvim#titlecase(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>")
(vim.cmd "nmap <leader>T :set opfunc=dotvim#titlecase<Bar>exe 'norm! 'v:count1.'g@_'<CR>")

(fn executable? [command]
        (nvim.fn.executable command))

; grepprog
(if (executable? "rg")
  ;then
  (do
     (set nvim.o.grepprg "rg  --vimgrep")
     (set nvim.o.grepformat "%f:%l:%c:%m"))
  (executable? "ag")
  ;then
  (set nvim.o.grepprg "ag --vimgrep")
  ;else
  (set nvim.o.grepprg "grep -R -n --exclude-dir=.git,.cache"))

; fennel stuff
(use [(:Olical/conjure {:opt true})
      :Olical/fennel.vim]

  (augroup :lazy_conjure
    [[:FileType "fennel"
      #(do
         (nvim.ex.packadd :conjure)
        (let [opts {:noremap true :silent true :buffer bufnr}]
        (u.map :o :if :ib {:buffer bufnr})
        (u.map :o :af :ab {:buffer bufnr})
        (u.map :o :is "i\"" {:buffer bufnr})
        (u.map :o :as "a\"" {:buffer bufnr})
        (u.map :n ")" "])" opts)
        (u.map :n "(" "[(" opts)
        (u.map :o ")" "])" {:buffer bufnr})
        (u.map :o "(" "[(" {:buffer bufnr}))
         ((. (require :conjure.mapping) :on-filetype)))]])

  (tset nvim.g
        :conjure#client#fennel#aniseed#aniseed_module_prefix
        "aniseed."))

; (use [(:nvim-treesitter/nvim-treesitter {:opt true :run (fn [] (nvim.ex.TSUpdate))})])

(use [:hrsh7th/nvim-compe]
     (let [compe (require :compe)]
       (compe.setup {
                     :enabled  true
                     :autocomplete  true
                     :debug  false
                     :min_length  1
                     :preselect  "enable"
                     :throttle_time  80
                     :source_timeout  200
                     :incomplete_delay  400
                     :max_abbr_width  100
                     :max_kind_width  100
                     :max_menu_width  100
                     :documentation  true
                     :source {
                              :path true
                              :buffer true
                              :nvim_lsp true
                              :tags true
                              :spell true
                              } })))

;; Aniseed compile on file save
(augroup :aniseed_compile_on_save
  [[:BufWritePost "~/*/*vim/*.fnl" #(let [e (require :aniseed.env)]
                                      (e.init))]])
(use [:tpope/vim-repeat
      :tpope/vim-commentary
      :tpope/vim-surround])

(use [(:tpope/vim-fugitive {:opt true })]
     (fn load-fugitive []
      (nvim.ex.packadd :vim-fugitive))
     ; lazy load vim-fugitive
     (u.noremap :n :Q ":Git<CR>")
     (vim.defer_fn load-fugitive 1500))

(use [:mhinz/vim-signify
      :justinmk/vim-dirvish
      :tommcdo/vim-lion])

;; finally snippets written in lisp (sorta
(use [:L3MON4D3/LuaSnip]
     (let [ls (require :luasnip)]
       (set ls.snippets 
            {:all
             [ (ls.s {:trig "trigger"}
                     [(ls.t ["wow1 text"])
                      (ls.i 0)])]})))


(use [:Gavinok/spaceway.vim]
     "Setup Colorscheme"
     (nvim.ex.colorscheme :spaceway)
     (nvim.ex.highlight "Normal ctermbg=NONE")
     (nvim.ex.highlight "Conceal ctermbg=NONE")
     (nvim.ex.highlight "Normal      guibg=NONE")
     (nvim.ex.highlight "ColorColumn guibg=NONE")
     (nvim.ex.highlight "SignColumn  guibg=NONE")
     (nvim.ex.highlight "Folded      guibg=NONE")
     (nvim.ex.highlight "Conceal     guibg=NONE")
     (nvim.ex.highlight "Terminal    guibg=NONE")
     (nvim.ex.highlight "LineNr      guibg=NONE"))

; (use [:axvr/org.vim]
;      (nvim.ex.highlight "link orgHeading2 Normal"))

(use [:dhruvasagar/vim-dotoo
      :emaniacs/OrgEval.vim]
     ; set autocmd for orgfiles
     ; should be replaced with fennel
     (vim.cmd
       "augroup org_is_dotoo
       autocmd! BufRead,BufNewFile *.org  setlocal filetype=dotoo
       augroup END")
     ; Viml: let g:dotoo#agenda#files = ['~/Documents/org/*.org']
     (set nvim.g.dotoo#agenda#files ["~/Documents/org/*.org"])
     (nvim.ex.highlight "dotoo_shade_stars ctermfg=NONE guifg='#000000'")
     (u.noremap :n :<leader>e ":OrgEval<CR>")
     (set nvim.g.org_eval_run_cmd
          {:python "python3"
           :clojure "clojure"
           :racket "racket"
           :slideshow "slideshow"
           :haskell "runhaskell"
           :sh "sh"
           :bash "bash"
           :awk "awk -f"
           :java "java --source 11"
           :c "tcc -run"
           :math "qalc"
           :apl "apl -s"
           :javascript "node"
           :r "Rscript -"}))

; floating completion
(use [:ncm2/float-preview.nvim]
     (set nvim.g.float_preview#docked  0))

; LSP setup
(local *lsp-attach-hook* {})
(use [(:neovim/nvim-lspconfig {:opt true})]

  (fn on-lsp-attach [client bufnr]
    ;; Mappings.
    (nvim.buf_set_option 0 "omnifunc" "v:lua.vim.lsp.omnifunc")
    (local opts {:noremap true :silent true :buffer bufnr})
    (map* :n opts
      {:gD    #(vim.lsp.buf.declaration)
       :gd    #(vim.lsp.buf.definition)
       :gR    #(vim.lsp.buf.references)
       :K     #(vim.lsp.buf.hover)
       :gi    #(vim.lsp.buf.implementation)
       :gs    #(vim.lsp.buf.signature_help)
       "[d"   #(vim.lsp.diagnostic.goto_prev)
       "]d"   #(vim.lsp.diagnostic.goto_next)
       :<LocalLeader>wa #(vim.lsp.buf.add_workspace_folder)
       :<LocalLeader>wr #(vim.lsp.buf.remove_workspace_folder)
       :<LocalLeader>wl #(a.pr (vim.lsp.buf.list_workspace_folders))
       :<LocalLeader>D  #(vim.lsp.buf.type_definition)
       :<LocalLeader>lr #(vim.lsp.buf.rename)
       :<LocalLeader>la #(vim.lsp.buf.code_action)
       :<LocalLeader>le #(vim.lsp.diagnostic.show_line_diagnostics)
       :<LocalLeader>lq #(vim.lsp.diagnostic.set_loclist)})

    ;; Set some keybinds conditional on server capabilities
    (if client.resolved_capabilities.document_formatting
      (u.map :n :<LocalLeader>gq #(vim.lsp.buf.formatting) opts))
    (if client.resolved_capabilities.document_range_formatting
      (u.map :v :<LocalLeader>gq #(vim.lsp.buf.range_formatting) opts))

    ;; Set autocommands conditional on server_capabilities
    (if client.resolved_capabilities.document_highlight
      (vim.cmd
        "hi def link LspReferenceText CursorLine
        hi def link LspReferenceWrite CursorLine
        hi def link LspReferenceRead CursorLine

        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END"))

    (u.run-hook *lsp-attach-hook* client bufnr))

  (u.defer-lsp-setup
    :jdtls ["java"]
    {:on_attach on-lsp-attach
     :cmd ["jdtls"]
     :root_dir #(let [lsp-config (require :lspconfig)]
                  (or nil
                      ; This seems to cause issues so nil is a place holder
                      ;((lsp-config.u.root_pattern "gradle.build" ".project" ".git") $1)
                      (vim.fn.getcwd)))})

  (u.defer-lsp-setup
    :ccls ["c" "cpp" "objc" "objcpp"]
    {:on_attach on-lsp-attach})

  (u.defer-lsp-setup
    :pyls ["python"]
    {:on_attach on-lsp-attach}))

(fn winmap [key]
  (do (u.noremap :n key (.. "<c-w>" key))
    (let [tesc "<c-\\><c-n>"]
      (u.noremap :t key (.. tesc
                            (.. "<c-w>"
                                key))))))

(winmap :<c-h>)
(winmap :<c-j>)
(winmap :<c-k>)
(winmap :<c-l>)

; better defaults
(u.map :n :Y  "y$")
(u.map :n :<esc> ":pclose" {:silent true})

; (u.map :c / (if (= (vim.api.nvim_eval "wildmenumode()") 1)
;                  (vim.api.nvim_feedkeys "<C-Y>" "n" true)
;                  (vim.api.nvim_feedkeys "/" "n" true)))

(u.noremap :n :<leader>/  ":nohlsearch" {:silent true})

; using autoload
(u.noremap :n :<leader>v  ":call dotvim#ToggleQuickfix()<CR>"        {:silent true})
(u.noremap :n :<leader>o  ":put =repeat(nr2char(10), v:count1)<CR>"  {:silent true})
(u.noremap :n :<leader>O  ":put! =repeat(nr2char(10), v:count1)<CR>" {:silent true})
(u.noremap :n :cd  ":cd <c-r>=expand('%:h')<CR>") ; should replace with just entering the keys

(u.noremap :n :<BS>         "mz[s1z=`z")

;; note that you can not use - in the middle of functions for it to work in neovim
(fn _G.sudosave []
  (vim.cmd (..
    ":w !sudo tee > /dev/null "
    (nvim.fn.expand "%"))))

(u.noremap :n :<leader>sudo ":lua sudosave()<CR>")
(u.noremap :n :<leader>co ":!opout %<CR>")

(u.noremap :n "]a" ":silent! cnext<CR>")
(u.noremap :n "[a" ":silent! cprevious<CR>")
(u.noremap :n "]A" ":silent! lnext<CR>")
(u.noremap :n "[A" ":silent! lprevious<CR>")

;quick buffer navigation
(u.noremap :n "]b" ":silent! bnext<CR>")
(u.noremap :n "[b" ":silent! bprevious<CR>")

; jumping between files
(u.noremap :n :<leader>b ":b <c-d>")

(u.noremap :n :<leader>y ":let @+ = expand('%:p')<CR>")

; (end-timer init-timer "Init loaded in %f msecs.")
