;; STXUSD - Over-Collateralized Stablecoin Protocol
;; Version: v1.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS AND ERRORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR-NO-VAULT (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-UNDER-COLLATERALIZED (err u103))
(define-constant ERR-ZERO-AMOUNT (err u104))

(define-constant BASE-RATIO u150) ;; 150% collateral ratio
(define-constant STXUSD-DECIMALS u6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ADMIN CONTROLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var admin principal tx-sender)
(define-data-var collateral-ratio uint BASE-RATIO)

(define-public (set-collateral-ratio (ratio uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-OWNER)
    (var-set collateral-ratio ratio)
    (print {event: "ratio-updated", new: ratio})
    (ok ratio)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VAULT STRUCTURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Each user -> {collateral, debt}
(define-map vaults
  {user: principal}
  {collateral: uint, debt: uint}
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CORE FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Deposit STX and mint stablecoins
(define-public (mint-stxusd (amount uint))
  (begin
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)

    ;; transfer collateral into contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    (let ((existing (default-to {collateral: u0, debt: u0} (map-get? vaults {user: tx-sender})))
          (new-collateral (+ (get collateral existing) amount))
          (mint-amount (/ (* amount u100) (var-get collateral-ratio)))
          (new-debt (+ (get debt existing) mint-amount)))
      (begin
        (map-set vaults {user: tx-sender} {collateral: new-collateral, debt: new-debt})
        (print {event: "minted", user: tx-sender, minted: mint-amount, collateral: new-collateral})
        (ok mint-amount)
      )
    )
  )
)

;; Repay debt and unlock collateral
(define-public (redeem-stx (repay-amount uint))
  (let ((vault (unwrap! (map-get? vaults {user: tx-sender}) ERR-NO-VAULT))
        (debt (get debt vault))
        (collateral (get collateral vault)))
    (begin
      (asserts! (> repay-amount u0) ERR-ZERO-AMOUNT)
      (asserts! (<= repay-amount debt) ERR-INSUFFICIENT-COLLATERAL)

      (let ((new-debt (- debt repay-amount))
            (unlock (/ (* repay-amount (var-get collateral-ratio)) u100)))
        (try! (stx-transfer? unlock (as-contract tx-sender) tx-sender))
        (map-set vaults {user: tx-sender} {collateral: (- collateral unlock), debt: new-debt})
        (print {event: "redeemed", user: tx-sender, unlocked: unlock})
        (ok unlock)
      )
    )
  )
)

;; Liquidate under-collateralized vaults
(define-public (liquidate (target principal))
  (let ((vault (unwrap! (map-get? vaults {user: target}) ERR-NO-VAULT))
        (ratio (var-get collateral-ratio))
        (collateral (get collateral vault))
        (debt (get debt vault)))
    (let ((collateral-value (/ (* collateral u100) ratio)))
      (if (< collateral-value debt)
          (begin
            (map-delete vaults {user: target})
            (try! (stx-transfer? collateral (as-contract tx-sender) tx-sender))
            (print {event: "liquidated", target: target, by: tx-sender, collateral: collateral})
            (ok collateral)
          )
          (err u400)
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ-ONLY FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-vault (user principal))
  (map-get? vaults {user: user})
)

(define-read-only (get-collateral-ratio)
  (var-get collateral-ratio)
)

(define-read-only (is-undercollateralized (user principal))
  (let ((vault (map-get? vaults {user: user})))
    (if (is-some vault)
        (let (
              (collateral (get collateral (unwrap-panic vault)))
              (debt (get debt (unwrap-panic vault)))
              (ratio (var-get collateral-ratio))
             )
          (ok (< (/ (* collateral u100) ratio) debt))
        )
        (ok false)
    )
  )
)
