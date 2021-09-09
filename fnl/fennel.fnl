(local u (require :util))
(local nvim (require :aniseed.nvim))

(if (u.executable? "fnlfmt")
  (do (set vim.o.formatprg "fnlfmt -")
    (set vim.o.formatexpr "")))

(set vim.bo.suffixesadd ".fnl")
(set vim.bo.keywordprg ":help")
(set vim.bo.define "(\\(fn\\|macro\\|lambda\\|λ\\)\\s\\zs\\w")
(set vim.bo.include "(\\(require\\-macros\\|import\\-macros\\|require\\)")
(set vim.bo.includeexpr "substitute(v:fname,'\\.','/','g')")
(set vim.o.lispwords (.. vim.o.lispwords ",collect,icollect,with-open"))
(u.noremap :n :gz ":ConjureEvalCurrentForm<CR>" {:buffer bufnr})
(nvim.ex.packadd :conjure)
(u.noremap :n :<leader>V ":ConjureLogSplit<CR>" {:buffer bufnr})

((. (require :conjure.mapping) :on-filetype))
