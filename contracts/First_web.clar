;; ----------------------------------------
;; To-Do List Smart Contract
;; Author: You
;; ----------------------------------------

(define-map todos
    {
        user: principal,
        id: uint,
    }
    {
        description: (string-ascii 100),
        completed: bool,
    }
)

(define-map todo-count
    { user: principal }
    { count: uint }
)

;; ----------------------------------------
;; Add a new to-do
;; ----------------------------------------
(define-public (add-todo (description (string-ascii 100)))
    (let (
            (user tx-sender)
            (current-count (default-to u0 (get count (map-get? todo-count { user: user }))))
            (new-id (+ current-count u1))
        )
        (map-set todo-count { user: user } { count: new-id })

        (map-set todos {
            user: user,
            id: new-id,
        } {
            description: description,
            completed: false,
        })

        (ok new-id)
    )
)

;; ----------------------------------------
;; Mark a to-do as completed
;; ----------------------------------------
(define-public (complete-todo (id uint))
    (match (map-get? todos {
        user: tx-sender,
        id: id,
    })
        todo (begin
            (map-set todos {
                user: tx-sender,
                id: id,
            } {
                description: (get description todo),
                completed: true,
            })
            (ok true)
        )
        (err u404)
    )
)

;; ----------------------------------------
;; Update to-do description
;; ----------------------------------------
(define-public (update-todo
        (id uint)
        (description (string-ascii 100))
    )
    (match (map-get? todos {
        user: tx-sender,
        id: id,
    })
        todo (begin
            (map-set todos {
                user: tx-sender,
                id: id,
            } {
                description: description,
                completed: (get completed todo),
            })
            (ok true)
        )
        (err u404)
    )
)

;; ----------------------------------------
;; Delete a to-do
;; ----------------------------------------
(define-public (delete-todo (id uint))
    (if (is-some (map-get? todos {
            user: tx-sender,
            id: id,
        }))
        (begin
            (map-delete todos {
                user: tx-sender,
                id: id,
            })
            (ok true)
        )
        (err u404)
    )
)

;; ----------------------------------------
;; Read-only: Get a specific to-do
;; ----------------------------------------
(define-read-only (get-todo
        (user principal)
        (id uint)
    )
    (map-get? todos {
        user: user,
        id: id,
    })
)

;; ----------------------------------------
;; Read-only: Get number of to-dos for user
;; ----------------------------------------
(define-read-only (get-todo-count (user principal))
    (default-to u0 (get count (map-get? todo-count { user: user })))
)