(local compe (require :compe))
(local Job (require :plenary.job))

(local Source [])

(fn Source.new []
  (let [self (setmetatable {} { :__index Source })]
    self))


(fn Source.get_metadata [ self ]
  {
   :priority  100
   :dup  0
   :menu  "[abook]"
   })

(fn Source.determine [self context]
  (compe.helper.determine context))

(fn Source.complete [self context]
  (self:collect 
    ;name currently being typed
    (context.context.line:match "%a+$")
    context.callback))

(fn Source.collect [self input callback]
  (var results [])
  (let [ job (Job:new {:command  "abook"
                       :args ["--mutt-query" input]
                       :on_stdout  (fn [_ data]
                                     (let [pieces (vim.split data  "\n"  true)]
                                       (each [ _ v (ipairs pieces) ]
                                         (let [ [email name] (vim.split v "\t" true) ]
                                           (table.insert results  {:word email
                                                                   :kind name
                                                                   :filter_text name }))))
                                     (callback {
                                                :items  results
                                                :incomplete  true
                                                }))})]
    (job:start))
  results)

(compe.register_source :abook Source)
