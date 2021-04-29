; example 1 https://github.com/steelsojka/dotfiles2/tree/107f53d112ee5a575af4d3a34b5b528294e5580e/.vim/fnl/dotfiles
; example 2 https://github.com/Olical/dotfiles/tree/master/stowed/.config/nvim/fnl/dotfiles
; example 3 https://www.github.com/Javyre/etc/tree/master/nvim%2Ffnl%2Finit.fnl

(fn begin-timer []
  (vim.loop.hrtime))

(fn end-timer [start msg?]
  (let [end (vim.loop.hrtime)
        msg (or msg? "Elapsed time: %f msecs")]
  (print (string.format msg (/ (- end start) 1000000)))))

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
(set nvim.g.maplocalleader ",") ; map local leader to ,
(set nvim.g.mapleader " ") ; map leader to space

(set nvim.o.undodir (.. (vim.fn.stdpath "cache") "/vim/undo/") )
(set nvim.o.undofile true)
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
  :list           true
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
  ; folds
  :foldmethod      "syntax"
  :foldlevel       99
  :wildmenu        true                   ;; Autocompletion of commands
  :wildmode        "longest:full,full"
  :wildignorecase  true
  :wildignore      "*.git/*,*.tags,tags,*.o,*.class,*.ccls-cache"
  :virtualedit     :block
  :undofile        true)

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

(use [(:Olical/conjure {:opt true})
      :Olical/fennel.vim]

  (augroup :lazy_conjure
    [[:FileType "fennel"
      #(do 
         (nvim.ex.packadd :conjure)
         ((. (require :conjure.mapping) :on-filetype)))]])

  (tset nvim.g 
        :conjure#client#fennel#aniseed#aniseed_module_prefix
        "aniseed."))

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
     (vim.defer_fn load-fugitive 1500))

(use [:mhinz/vim-signify
      :justinmk/vim-dirvish
      :tommcdo/vim-lion])

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

(use [:axvr/org.vim]
     (nvim.ex.highlight "link orgHeading2 Normal"))

; floating completion
(use [:ncm2/float-preview.nvim]
     (set nvim.g.float_preview#docked  0))

; LSP setup
(local *lsp-attach-hook* {})
(use [:neovim/nvim-lspconfig]

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
       :gs #(vim.lsp.buf.signature_help)
       "[d" #(vim.lsp.diagnostic.goto_prev)
       "]d" #(vim.lsp.diagnostic.goto_next)
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
      (u.map :n :<LocalLeader>lf #(vim.lsp.buf.formatting) opts))
    (if client.resolved_capabilities.document_range_formatting
      (u.map :v :<LocalLeader>lf #(vim.lsp.buf.range_formatting) opts))

    ;; Set autocommands conditional on server_capabilities
    (if client.resolved_capabilities.document_highlight
      (vim.api.nvim_exec
        "hi def link LspReferenceText CursorLine
        hi def link LspReferenceWrite CursorLine
        hi def link LspReferenceRead CursorLine

        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END" false))

    (u.run-hook *lsp-attach-hook* client bufnr))

  (u.defer-lsp-setup
    :jdtls ["java"]
    {:on_attach on-lsp-attach
     :cmd ["jdtls"]
     :root_dir #(let [lsp-config (require :lspconfig)]
                  (or ((lsp-config.u.root_pattern
                         "gradle.build" ".project" ".git") $1)
                      (vim.fn.getcwd)))})

  (u.defer-lsp-setup
    :ccls ["c" "cpp" "objc" "objcpp"]
    {:on_attach on-lsp-attach})

  (u.defer-lsp-setup
    :pyls ["python"]
    {:on_attach on-lsp-attach}))


(u.map :n  :<c-k>  "<c-w><c-k>")
(u.map :n  :<c-j>  "<c-w><c-j>")
(u.map :n  :<c-l>  "<c-w><c-l>")
(u.map :n  :<c-h>  "<c-w><c-h>")

; better defaults
(u.map :n :Y  "y$")
(u.map :n :<esc> ":pclose" {:silent true})

; (u.map :c / (if (= (vim.api.nvim_eval "wildmenumode()") 1)
;                  (vim.api.nvim_feedkeys "<C-Y>" "n" true)
;                  (vim.api.nvim_feedkeys "/" "n" true)))

; using autoload
(u.map :n :<leader>v  ":call dotvim#ToggleQuickfix()")
(u.map :n :<leader>o  ":put =repeat(nr2char(10), v:count1)" { :silent true })
(u.map :n :<leader>O  ":put! =repeat(nr2char(10), v:count1)" {:silent true})
(u.map :n :cd  (.. ":cd " (vim.api.nvim_eval "expand('%:h')"))) ; should replace with just entering the keys

(u.noremap :n :<BS>         "mz[s1z=`z")

(u.noremap :n :<leader>sudo (.. ":w !sudo tee > /dev/null " (vim.api.nvim_eval "expand('%')")))
(u.noremap :n :<leader>co (..
                            ":!opout "
                            (vim.api.nvim_eval "expand('%')")))

; jumping between files
; (u.noremap :n :<leader>b ())
; (end-timer init-timer "Init loaded in %f msecs.")
