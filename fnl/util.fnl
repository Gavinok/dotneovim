; vim:lispwords+=a.assoc,augroup

(local a    (require :aniseed.core))
(local nvim (require :aniseed.nvim))
(local nu   (require :aniseed.nvim.util))
;; Keymap

(local *targ-fns* {})

(fn escape-vim-keys [s]
  (s:gsub "<" "<lt>"))

(fn fn->cmd [f ident]
  "Takes a function F and a keyword IDENT used to create a viml command"
  (match (type f)
    :function (let [ident (match (type ident)
                            :function (ident)
                            _ ident)]
                (tset *targ-fns* ident f)
                (string.format "lua require'%s'.targ_fns['%s']()"
                               :util ident))
    :string   f))

(fn fn->keys [f mode from bufnr buffer-local] 
  "Takes a function F a MODE it is effective in the key FROM which to map
  the buffernumber BUFNR it is local to and if the mapping is BUFFER-LOCAL"

  (match (type f)
    :function (let [ident (string.format 
                            "%s-%s-%s"
                            (if buffer-local (string.format "b-%s" bufnr) :g)
                            mode from)]
                (.. ":" (escape-vim-keys (fn->cmd f ident))))
    :string   f))

(fn wrap-cmd [s]
  (match (s:sub 1 1)
    ":" (string.format "<Cmd>%s<CR>" (s:sub 2 -1))
    _   s))

(fn map [mode from to opts]
  "Sets a global mapping with opts.
  TO can be a string mapping or a lua function"
  (let [bufnr (a.get opts :buffer)
        buffer-local (= (type bufnr) :number)
        to (-> to
               (fn->keys mode from bufnr buffer-local)
               (wrap-cmd))]
    (if buffer-local
      (nvim.buf_set_keymap
        bufnr mode from to (a.assoc (vim.deepcopy opts) :buffer nil))
      (nvim.set_keymap
        mode from to (or opts {})))))

(fn iabr [from to]
  "Shorthand for creating abbreviations FROM some input TO some output"
  (vim.cmd (.. "iabbrev "
               from " "
               to)))

(fn noremap [mode from to opt]
  "Sets a mapping with {:noremap true}."
  (if (= opt nil)
  (nvim.set_keymap mode from to {:noremap true})
  (nvim.set_keymap mode from to (do
                                  (tset opt :noremap true)
                                  opt))))

(fn map* [mode opts binds]
  "Set multiple bindings"
  (each [from to (pairs binds)]
    (map mode from to opts)))

(fn augroup [name ...]
  (nvim.ex.augroup name)
  (nvim.ex.autocmd!)
  (each [_ [event pat cmd] (ipairs ...)]
    (let [cmd (fn->cmd cmd #(.. name event pat))]
      (nvim.ex.autocmd event pat cmd)))
  (nvim.ex.augroup :END))

;; Hooks

(fn run-hook [hook ...]
  (each [fun _ (pairs hook)]
    (fun ...)))

(fn add-hook [hook fun]
  (a.assoc hook fun true))

;; LSP

(local *lsp-defer* {})
(local *lsp-init-hook* {})

(fn defer-lsp-setup [serv filetypes opts]
  (augroup (.. "lsp_defer_" serv)
    [[:FileType (table.concat filetypes ",") 
      #(when (= (. *lsp-defer* serv) nil)
        (nvim.ex.packadd :nvim-lspconfig)
         (when (= *lsp-defer*.-defer-init nil)
           (set *lsp-defer*.-defer-init true)
           (run-hook *lsp-init-hook*))

         (let [lsp (. (require :lspconfig) serv)]
           (a.assoc *lsp-defer* serv true)
           (lsp.setup (do (tset opts :filetypes filetypes) opts))
           (lsp.manager.try_add)))]]))

(fn executable? [command]
        (nvim.fn.executable command))

{:targ_fns *targ-fns*
            : iabr
            : map
            : fn->cmd
            : noremap
            : augroup
            : run-hook
            : add-hook
            :lsp-init-hook *lsp-init-hook*
            : defer-lsp-setup
            : executable?}
