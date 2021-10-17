(local u    (require :util))

(fn _G._m_key_override []
  (do
    (vim.cmd (.. "normal! m" (vim.fn.nr2char (vim.fn.getchar))))
    (showmarks)))

(fn _G.showmarks []
  (let [marks (vim.fn.getmarklist "%")
        ns :dotneovim
        buffer 0]
    (vim.api.nvim_buf_clear_namespace buffer -1 0 -1)
    (each [_ {:mark name :pos [_ lnum _ _]} (ipairs marks)]
      (vim.api.nvim_buf_set_virtual_text buffer
                                         (vim.api.nvim_create_namespace ns)
                                         (- lnum 1) [[name :NonText]] {}))))

(u.augroup :load_marks
         [["BufReadPost" "*" #(showmarks)]])
(u.map :n :m #(_m_key_override))
