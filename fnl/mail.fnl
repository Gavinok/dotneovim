(local u    (require :util))
(local a    (require :aniseed.core))
(local print a.println)

;https://github.com/norcalli/nvim.lua
(local nvim (require :aniseed.nvim))
; (local str  (require :aniseed.string))
(local paq  (require :paq-nvim))

(require-macros :macros)

(local augroup u.augroup)
(local iabr u.iabr)
(fn mail_setup []
  "Get content from an email header and return it as a string
  id the regex for the key 
  ptrn the pattern to match the value
  lnum is the optional starting line
  returns a string containing that mail parameter"
  (do
    (fn mail-param [id  ptrn ?lnum]
      (let [bufnr (nvim.fn.bufnr "%")
            lnum  (or ?lnum 0)
            line  (nvim.fn.getline (or ?lnum 0))
            max   (vim.fn.line "$")]
        (if (>= lnum max)
          :error
          (match (line:match
                   (.. id ptrn))
            str (let [ (text _) (: str :gsub id "" 1)]
                  text)
            nil (mail-param id ptrn (+ lnum 1))))))
    (set vim.b.mail_my_name "Gavin Jaeger-Freeborn")
    (set nvim.b.mail_from (mail-param "^From: " "%a+" 1))
    (u.iabr "tt" (.. "<c-o>:" (u.func-to-cmd #(print "hello") :tt) "<CR>"))
    (u.iabr "hey" (.. "Hey <c-o>:"
                      (u.func-to-cmd #(set vim.b.mail_to (mail-param "^To: " "%a+")) :To) "<CR>"
                      "<c-r>=b:mail_to<CR>,<CR>"))
    (u.iabr "hello" (.. "Hello <c-o>:"
                        (u.func-to-cmd #(set vim.b.mail_to (mail-param "^To: " "%a+")) :To) "<CR>"
                        "<c-r>=b:mail_to<CR>,<CR>"))
    (u.iabr "Hope" "Hope you are doing well.")
    (u.iabr "questions?" "If you have any questions don't hesitate to contact me.")
    (u.iabr "thx"  "Thanks,<CR><c-r>=b:mail_my_name<CR>")
    (u.iabr "sin" "Sincerely,<CR><c-r>=b:mail_my_name<CR>")))
(vim.defer_fn mail_setup 300)
