(fn lazy-require [module]
  `(let [meta# {:__index #(. (require ,module) $2)}
         ret# {}]
     (setmetatable ret# meta#)
     ret#))

(fn map* [mode opts binds]
  (let [util (gensym)
        opts-sym (gensym)
        binds (icollect [from to (pairs binds)]
                `((. ,util :map) ,mode ,from ,to ,opts-sym))]
    `(let [,util (require :util)
           ,opts-sym ,opts]
       ,(values (unpack binds)))))

;; Paq
(fn use--paq [plug] 
  (if (list? plug)
    (do 
      (tset plug 2 1 (. plug 1))
      `(paq.paq ,(. plug 2)))
    `(paq.paq ,plug)))

(fn use [plug ...]
  (if (sequence? plug)
    (let [paqs (icollect [_ p (ipairs plug)]
                 (use--paq p))]
      `(do (do ,(values (unpack paqs))) ,...))
    `(do ,(use--paq plug) ,...)))

{: lazy-require
 : map*
 : use}
