;; Examples:
;; 	https://github.com/steelsojka/dotfiles2/tree/107f53d112ee5a575af4d3a34b5b528294e5580e/.vim/fnl/dotfiles
;; 	https://github.com/Olical/dotfiles/tree/master/stowed/.config/nvim/fnl/dotfiles
;; 	https://www.github.com/Javyre/etc/tree/master/nvim%2Ffnl%2Finit.fnl
;; 	https://gitlab.com/TravonteD/neovim-config
;; 	https://github.com/tsbohc/.garden/tree/master/etc/nvim.d

;; Automatic documentation https://gitlab.com/andreyorst/fenneldoc
;; lua guid https://github.com/nanotee/nvim-lua-guide
;; TODO setup drawing with :set virtualedit=all

(fn begin-timer []
  (vim.loop.hrtime))

(fn end-timer [start msg?]
  (let [end (vim.loop.hrtime)
        msg (or msg? "Elapsed time: %f msecs")]
   (print (string.format msg (/ (- end start) 1000000)))))
(local u    (require :util))
(local a    (require :aniseed.core))

;https://github.com/norcalli/nvim.lua
(local nvim (require :aniseed.nvim))
(local paq  (require :paq-nvim))

(require-macros :macros)
;; Solo Files
(require :marks)

(local executable? u.executable?)
(local augroup u.augroup)
(local iabr u.iabr)

;; leader
;; leader is still set to \ but mapped to space
(set vim.g.maplocalleader ",") ; map local leader to ,
(u.map :n  :<space>  :<leader>)
(u.map :x  :<space>  :<leader>)
;; Undo
(set vim.o.undodir (.. (vim.fn.stdpath "cache") "/vim/undo/"))

 ;; for some reason (set nvim.o.undofile true) won't work
(nvim.ex.set :undofile)
(nvim.ex.set :list)
  ; folds
(vim.cmd ":set foldmethod=syntax")
(vim.cmd ":set foldlevel=99")

(a.assoc vim.o
         :mouse          :a
         :title          true                    ;; Update window title
         :hidden         true                    ;; Allow to leave buffer without saving
         :showcmd        true                    ;; Show keys pressed in normal
         :lazyredraw     true
         :shortmess      :aAtcT                  ;; Get rid of annoying messages
         ; Tags
         :tags           ".tags,tags"            ;; Make tag files hidden
         :tagcase        :match                  ;; Match case when searching for tags
         ; Whitespace
         :listchars      "tab:→ ,trail:·,nbsp:·" ;; Show white space
         ; Indentation
         :tabstop        4                       ;; Shorter hard tabs
         :softtabstop    0                       ;; No spaces
         :smarttab       true
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
         ; splits
         :splitbelow     true                    ;; open below instead of above
         :splitright     true                    ;; open right instead of left
         ;
         :clipboard      "unnamed,unnamedplus"   ;; xclip support
         :fillchars      "fold: ,diff: "
         ; substitution
         :inccommand     :split
         :gdefault       true                    ;; global substitution by default (no need for /g flag)
         :diffopt                                ;; smarter diff
         (.. (or vim.o.diffopt "") ",indent-heuristic,algorithm:histogram")
         :wildmenu        true                   ;; Autocompletion of commands
         :wildignorecase  true
         :wildmode        "longest:full,full"
         :wildignore      "*.git/*,*.tags,tags,*.o,*.class,*.ccls-cache"
         :virtualedit     :block)

; Grepprg
(if (executable? "rg")
  ;;then
  (do
     (set vim.o.grepprg "rg  --vimgrep")
     (set vim.o.grepformat "%f:%l:%c:%m"))
  (executable? "ag")
  ;then
  (set vim.o.grepprg "ag --vimgrep")
  ;else
  (set vim.o.grepprg "grep -R -n --exclude-dir=.git,.cache"))

; Capital Quick first letter of a word or a regain
; should eventually be replaced  with fennel
(vim.cmd "nmap <leader>t :set opfunc=dotvim#titlecase<CR>g@")
(vim.cmd "xmap <leader>t :<C-U>call dotvim#titlecase(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>")
(vim.cmd "nmap <leader>T :set opfunc=dotvim#titlecase<Bar>exe 'norm! 'v:count1.'g@_'<CR>")

(use [:axvr/zepl.vim]
     (set vim.g.repl_config  {:clojure    { :cmd "joker --no-readline" }
                               :apl        { :cmd "apl" }
                               :elm        { :cmd "elm repl" }
                               :sh         { :cmd "dash" }
                               :python     { :cmd "python" }
                               :scheme     { :cmd "racket" }
                               :racket     { :cmd "racket" }
                               :fennel     { :cmd "fennel" }
                               :math       { :cmd "qalc" }
                               :javascript { :cmd "node" } }))

(augroup :aniseed_compile_on_save
         [[:BufWritePost "~/*/*vim/*.fnl" #(let [e (require :aniseed.env)]
                                             (e.init))]]
     (let [filetypes [ :fennel :clojure :racket :scheme :lisp]]
       "lisp settings"
       (augroup :lisp_settings
                [[:FileType (table.concat filetypes ",")
                  #(let [nopts {:noremap true :silent true :buffer bufnr}
                         buf {:buffer bufnr}]
                     (nvim.ex.setlocal :expandtab)
                     (map* :o buf
                           {:if :ib 
                            ")" "])" 
                            :af :ab  
                            :is "i\""
                            :as "a\""
                            "(" "[("}) 
                     (map* :n nopts
                           {")" "])"
                            "(" "[("}))]])))

;; fennel stuff
(use [:milisims/nvim-luaref])

(use [(:Olical/conjure {:opt true})]
     "Set Up Neovim For Fennel Development"
     (tset vim.g
           :conjure#client#fennel#aniseed#aniseed_module_prefix
           "aniseed."))

(use [:tpope/vim-repeat
      :tpope/vim-commentary
      :tpope/vim-surround])

(use [(:tpope/vim-fugitive {:opt true})
      (:mhinz/vim-signify {:opt true})]
     (fn load-fugitive []
       "lazy load vim-fugitive and vim-signify"
       (nvim.ex.packadd :vim-fugitive)
       (nvim.ex.packadd :vim-signify)
       (vim.cmd "SignifyEnable"))
     (vim.defer_fn load-fugitive 1500)
     (u.noremap :n :Q ":Git<CR>")
     (vim.cmd
       "command! -bang -nargs=? -range=-1 Git packadd vim-fugitive | Git"))

(use [:justinmk/vim-dirvish
      :tommcdo/vim-lion])

(use [:Gavinok/spaceway.vim]
     "Setup Colorscheme"
     (set vim.o.termguicolors true)
     (nvim.ex.colorscheme :spaceway)
     (nvim.ex.highlight "Normal      ctermbg=NONE")
     (nvim.ex.highlight "Conceal     ctermbg=NONE")
     (nvim.ex.highlight "Normal      guibg=NONE")
     (nvim.ex.highlight "ColorColumn guibg=NONE")
     (nvim.ex.highlight "SignColumn  guibg=NONE")
     (nvim.ex.highlight "Folded      guibg=NONE")
     (nvim.ex.highlight "Conceal     guibg=NONE")
     (nvim.ex.highlight "Terminal    guibg=NONE")
     (nvim.ex.highlight "LineNr      guibg=NONE"))

(use [:norcalli/nvim-colorizer.lua]
     (let [col (require :colorizer)]
       (col.setup)))

(use [:NFrid/due.nvim]
     (let [due (require :due_nvim)]
       (due.setup {:prescript  "due: "           ; prescript to due data
                   :prescript_hi  "Comment"      ; highlight group of it
                   :due_hi  "String"             ; highlight group of the data itself
                   :ft  "*.org"                   ; filename template to apply aucmds :)
                   :today  "TODAY"               ; text for today's due
                   :today_hi  "Character"        ; highlight group of today's due
                   :overdue  "OVERDUE"           ; text for overdued
                   :overdue_hi  "Error"          ; highlight group of overdued
                   :date_hi  "Conceal"           ; highlight group of date string
                   :pattern_start  "<"           ; start for a date string pattern
                   :pattern_end  ">"             ; end for a date string pattern
                   :use_clock_time  false        ; allow due.nvim to calculate hours, minutes, and seconds
                   :default_due_time  "midnight" ; if use_clock_time  true, calculate time until option on specified date. 
                   ;   Accepts "midnight", for 23:59:59, or noon, for 12:00:00
                   })))

(use [:kristijanhusak/orgmode.nvim
      :Gavinok/OrgEval.vim
      (:dhruvasagar/vim-table-mode {:opt true})]
     "Setup Vim For Use With Org Files"
     (let [org (require :orgmode)]
       (org.setup {
                   :org_agenda_file "~/Documents/org/*"
                   :org_default_notes_file "~/Documents/org/refile.org"
                   :mappings { :global {:org_agenda "gA"
                                        :org_capture "gC"
                                        }}}))
     ; set autocmd for orgfiles
     ; should be replaced with fennel
     ; Viml: let g:dotoo#agenda#files = ['~/Documents/org/*.org']
     (set vim.g.dotoo#agenda#files ["~/Documents/org/*.org"])
     (set vim.g.dotoo#agenda#warning_days  "30d")
     (set vim.g.dotoo_disable_mappings 0)
     (set vim.g.dotoo#agenda_view#agenda#start_of  "today")
     (set vim.g.dotoo#agenda_views#agenda#span  "week")
     (set vim.g.dotoo_begin_src_languages ["vim" "clojure" "scheme" "fennel" "lua" "sql"])
     (nvim.ex.highlight "dotoo_shade_stars ctermfg=NONE guifg=#000000")
     (vim.cmd ":set conceallevel=2")
     (u.noremap :n :gO ":e ~/Documents/org<CR>"  {:silent true })
     ; (u.noremap :n :gC ":call CreateCapture('split')<CR>" {:silent true })
     (augroup :org_settings
              [[:FileType :dotoo #(let [opts {:buffer bufnr :silent true}]
                                    (set vim.b.omnifunc "dotoo#autocompletion#omni")
                                    (u.noremap :n :<leader>e ":OrgEval<CR>" opts)
                                    (u.noremap :n :<leader>E ":call org_eval#OrgToggleEdit()<CR>" opts)
                                    (u.map     :n :cid       ":call ChangeDate()" opts)
                                    (nvim.ex.setlocal :nowrap))]])
     (set vim.g.org_eval_run_cmd
          {:python "python3"
           :elm  "elm repl"
           :clojure "joker"
           :lisp "janet"
           :racket "racket"
           :scheme "guile"
           :slideshow "slideshow"
           :fennel "fennel"
           :hy "hy"
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

; why did no one tell me you can use viml in vsnip
(use [(:hrsh7th/vim-vsnip {:opt true})]
     (fn load-vsnip []
       (vim.cmd "packadd vim-vsnip")
       (set vim.g.name  "Gavin Jaeger-Freeborn")
       (set vim.g.email  "gavinfreeborn@gmail.com")
       (set vim.g.vsnip_snippet_dir (vim.fn.globpath vim.o.runtimepath "**/*vsnips")))
     (vim.defer_fn load-vsnip 600))

;; What langs need word processor settings
(set vim.g.writing_langs
     [
      ;general
      :mail :gitcommit
      ;markup
      :markdown :dotoo :html
      ;roff & tex
      :groff :troff :tex
      ])

(augroup :writing
         [[:FileType (table.concat vim.g.writing_langs ",")
           #(let [opt {:buffer bufnr :silent true}]
              (nvim.ex.setlocal :spell)
              (nvim.ex.setlocal :expandtab)
              (nvim.ex.setlocal :shiftwidth=2)
              (nvim.ex.setlocal :softtabstop=2))]])

(use [:hrsh7th/nvim-compe
      :Shougo/neco-syntax
      :tamago324/compe-necosyntax
      :nvim-lua/plenary.nvim
      :Gavinok/compe-nextword
      :Gavinok/compe-look
      :Gavinok/compe-abook]
     (set vim.o.completeopt "menuone,noselect")
     (set vim.o.dictionary "/usr/share/dict/words" )
     (let [compe (require :compe)]
       (compe.setup {:enabled true
                     :autocomplete true
                     :debug false
                     :min_length 1
                     :preselect :enable
                     :throttle_time 80
                     :source_timeout 200
                     :incomplete_delay 400
                     :max_abbr_width 100
                     :max_kind_width 100
                     :max_menu_width 100
                     :documentation true
                     :source {
                              :vsnip      true
                              :nvim_lsp   true
                              :path       true
                              ; :tabnine  true
                              :calc       true
                              :tags       true
                              :buffer     true
                              :abook      {:filetypes [:mail]}
                              :necosyntax {:filetypes [:make :muttrc]}
                              :spell      {:filetypes vim.g.writing_langs}
                              :nextword   {:filetypes vim.g.writing_langs}
                              :emoji      {:filetypes vim.g.writing_langs}
                              :look       {:filetypes vim.g.writing_langs}
                              }}))

       (fn t [str]
         (vim.api.nvim_replace_termcodes str true true true))

       (fn check_back_space []
         (let [col (- (vim.fn.col ".") 1)]
           (if (or (= col 0) (: (: (vim.fn.getline ".") :sub col col) :match
                                "%s")) true false)))

       (fn _G.tab_complete []
         (if (= (vim.fn.pumvisible) 1) ;then
           (t :<C-n>) ;if
           (check_back_space) ;;then
           (t :<Tab>) ;else
           (nvim.fn.compe#complete)))

       (fn _G.s_tab_complete []
         (if (= (vim.fn.pumvisible) 1)
           (t :<C-p>) ;else
           (t :<S-Tab>)))

       (fn _G.smart_confirm []
         (let [c-f #(if (= (vim.fn.vsnip#available 1) 1)
                      (t "<Plug>(vsnip-expand-or-jump)") (t :<Right>))]
           (if (= (vim.fn.pumvisible) 1)
             (vim.fn.compe#confirm (c-f))
             (c-f))))

       (vim.api.nvim_set_keymap :i :<C-F> "v:lua.smart_confirm()"    {:expr true})
       (vim.api.nvim_set_keymap :s :<C-F> "v:lua.smart_confirm()"    {:expr true})

       (vim.api.nvim_set_keymap :i :<Tab>   "v:lua.tab_complete()"   {:expr true})
       (vim.api.nvim_set_keymap :i :<S-Tab> "v:lua.s_tab_complete()" {:expr true})
       (nvim.ex.inoremap "<silent><expr> <C-X><C-X> compe#complete()"))

(local *lsp-attach-hook* {})

(use [(:weilbith/nvim-lsp-smag {:opt true})]
     (u.add-hook *lsp-attach-hook* 
               #(nvim.ex.packadd :nvim-lsp-smag)))

(use [(:neovim/nvim-lspconfig {:opt true})
      :ray-x/lsp_signature.nvim]
     "Setup Lsp Support For Different Languages"
     (fn on-lsp-attach [client bufnr]
       ;; customize diagnostics
       (let [errr "#EB4917"
             warn "#EBA217"
             info "#17D6EB"
             hint "#17EB7A"
             ext  " gui=undercurl\n"]
         (set vim.lsp.handlers.textDocument/publishDiagnostics
              (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics {; Disable virtual_text
                                                                       :virtual_text false
                                                                       :signs false}))
         (vim.lsp.set_log_level "debug")
         (vim.cmd (..
                    "highlight LspDiagnosticsUnderlineError       guifg=#000000 guibg=" errr ext
                    "highlight LspDiagnosticsUnderlineWarning     guifg=#000000 guibg=" warn ext
                    "highlight LspDiagnosticsUnderlineInformation guifg=#000000 guibg=" info ext
                    "highlight LspDiagnosticsUnderlineHint        guifg=#000000 guibg=" hint ext)))
       (local opts {:noremap true :silent true :buffer bufnr})
       ;; set keywordprg for programs that have support
       (if (= vim.o.keywordprg ":Man")
         (set vim.bo.keywordprg ":call v:lua.vim.lsp.buf.hover()\""))
       (map* :n opts
             {:gD              #(vim.lsp.buf.declaration)
              :gd              #(vim.lsp.buf.definition)
              :gR              #(vim.lsp.buf.references)
              :gi              #(vim.lsp.buf.implementation)
              :gs              #(vim.lsp.buf.signature_help)
              "[d"             #(vim.lsp.diagnostic.goto_prev)
              "]d"             #(vim.lsp.diagnostic.goto_next)
              :<Leader>V       #(vim.lsp.diagnostic.set_loclist)
              :<Leader>D       #(vim.lsp.buf.type_definition)
              :<Leader>wa      #(vim.lsp.buf.add_workspace_folder)
              :<Leader>wr      #(vim.lsp.buf.remove_workspace_folder)
              :<Leader>wl      #(print (vim.lsp.buf.list_workspace_folders))
              :<Leader>lr      #(vim.lsp.buf.rename)
              :<Leader>la      #(vim.lsp.buf.code_action)
              :<Leader>le      #(vim.lsp.diagnostic.show_line_diagnostics)})

    ;; Set some keybinds conditional on server capabilities
      (if client.resolved_capabilities.document_formatting
        (u.map :n :<Leader>gq #(vim.lsp.buf.formatting) opts))
      (if client.resolved_capabilities.document_range_formatting
        (u.map :v :<Leader>gq #(vim.lsp.buf.range_formatting) opts))

    ;; Set autocommands conditional on server_capabilities
      (if client.resolved_capabilities.document_highlight
        (vim.cmd
          "
          hi def link LspReferenceText CursorLine
          hi def link LspReferenceWrite CursorLine
          hi def link LspReferenceRead CursorLine

          augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END"))

      (u.run-hook *lsp-attach-hook* client bufnr))

  (u.defer-lsp-setup :jdtls
                     [:java]
    {:on_attach on-lsp-attach
     :cmd ["jdtls"]
     :root_dir #(let [lsp (require :lspconfig)]
                  (or
                    ((lsp.util.root_pattern "gradle.build" ".project" ".git") $1)
                    (lsp.util.path.dirname $1)))})

  (u.defer-lsp-setup :ccls
                     [:c :cpp :objc :objcpp]
                     {:init_options { :cache { "directory" "/tmp/ccls-cache" } }
                      :on_attach on-lsp-attach})

  (u.defer-lsp-setup :pyls
                     [:python]
    {:on_attach on-lsp-attach})

  (u.defer-lsp-setup :efm
                     [:clojure :fennel :sh (table.concat vim.g.writing_langs ",")]
    {:on_attach on-lsp-attach
     :root_dir #(let [lsp (require :lspconfig)]
                  (or
                    ((lsp.util.root_pattern "settings.gradle" ".git")
                     $1)
                    (lsp.util.path.dirname $1)))})

  (u.defer-lsp-setup :racket_langserver
                     [ :racket :scheme ]
    {:on_attach on-lsp-attach})

  (u.defer-lsp-setup :elmls
                     [:elm]
                     {:on_attach on-lsp-attach})
)

;; Shortcuts
(u.noremap :n :<leader>ft  ":setfiletype<space>") ; for filetype
(u.noremap :n :<leader>hh  ":help<Space>")        ; for help
(u.noremap :n :<leader>ff  ":e ")
(u.noremap :n :<leader>b   ":b ")

;; Improved command completion
(use [(:gelguy/wilder.nvim {:run (fn [] (vim.cmd "UpdateRemotePlugins"))})]
     ; (vim.cmd (.. "call wilder#set_option('use_python_remote_plugin',0)"))
     (vim.cmd (.. "call wilder#set_option('renderer', wilder#popupmenu_renderer("
                  "wilder#popupmenu_border_theme({"
                  " 'highlighter': wilder#basic_highlighter(),"
                  " 'highlights': {"
                  "   'default': wilder#make_hl('WildBG', 'Pmenu', [{}, {}, {'background': '#000000'}]),"
                  "   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#f4468f', 'background': '#000000'}]),"
                  " },"
                  " 'min_width': '100%',"
                  " 'max_height': '30%',"
                  " })))"))
     (vim.cmd (.. " call wilder#setup({"
                  " 'modes': [':', '/', '?'],"
                  " 'next_key': '<Tab>',"
                  " 'previous_key': '<S-Tab>',"
                  " 'accept_key': '<Down>',"
                  " 'reject_key': '<Up>',"
                  " })")))

(let [winmap (fn [key]
               (let [tesc "<c-\\><c-n>"]
                 (do (u.noremap :n key (.. "<c-w>" key))
                   (u.noremap :t key (.. tesc
                                         (.. "<c-w>"
                                             key))))))]
  (winmap :<c-h>)
  (winmap :<c-j>)
  (winmap :<c-k>)
  (winmap :<c-l>))

; better defaults
(u.noremap :n :Y  "y$")
(u.map :n :<esc> ":pclose" {:silent true})

(u.noremap :n :<leader>/ ":nohlsearch<CR>" {:silent true})

;; Toggle Quickfix
(u.noremap :n :<leader>v  ":call dotvim#ToggleQuickfix()<CR>"        {:silent true})

;; Insert Blank Lines
(u.noremap :n :<leader>o  ":put =repeat(nr2char(10), v:count1)<CR>"  {:silent true})
(u.noremap :n :<leader>O  ":put! =repeat(nr2char(10), v:count1)<CR>" {:silent true})
(u.noremap :n :cd         ":cd <c-r>=expand('%:h')<CR>") ; should replace with just entering the keys

(u.noremap :n :<BS>         "mz[s1z=`z")

;; note that you can not use - in the middle of functions for it to work in neovim
(u.map :n :<leader>sudo #(vim.cmd (..
                                    ":w !sudo tee > /dev/null "
                                    (nvim.fn.expand "%"))) {:silent true})

(u.noremap :n :<leader>co ":!opout %<CR>")

(u.noremap :n "]a" ":silent! cnext<CR>")
(u.noremap :n "[a" ":silent! cprevious<CR>")
(u.noremap :n "]A" ":silent! lnext<CR>")
(u.noremap :n "[A" ":silent! lprevious<CR>")

;; Quick buffer navigation
(u.noremap :n "]b" ":silent! bnext<CR>")
(u.noremap :n "[b" ":silent! bprevious<CR>")
; (u.noremap :n :<leader>b ":b <c-d>")

(u.map :n :ga #(do
                 (vim.cmd (.. "split | term "
                              ;; auto start emacsclient
                              "emacsclient -nw -c -a= --eval "
                              ;; run normal startup hooks
                              "\"(run-hooks 'emacs-startup-hook)\"" " --eval "
                              ;; display agenda
                              "'(progn (org-batch-agenda \"d\")(delete-other-windows))'"))
                 (vim.cmd "normal i")))

;; For Proper Tabbing And Bracket Insertion
(u.noremap :i "{<CR>" "{<CR>}<c-o><s-o>")
(u.noremap :i "(<CR>" "(<CR>)<c-o><s-o>")
(u.noremap :n :<leader>y ":let @+ = expand('%:p')<CR>")
