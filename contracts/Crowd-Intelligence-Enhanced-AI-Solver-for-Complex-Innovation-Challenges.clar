;; Crowd-Intelligence-Enhanced AI Solver for Complex Innovation Challenges
;; A hybrid platform combining human crowd intelligence with AI assistance for solving complex problems
;; Version: 1.0.0
;; Compatible with: Clarinet 3.x

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_CHALLENGE_NOT_FOUND (err u404))
(define-constant ERR_SOLUTION_NOT_FOUND (err u405))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_INVALID_PARAMETERS (err u400))
(define-constant ERR_CHALLENGE_CLOSED (err u408))
(define-constant ERR_ALREADY_CONTRIBUTED (err u409))
(define-constant ERR_INSUFFICIENT_REPUTATION (err u407))
(define-constant ERR_AI_ANALYSIS_PENDING (err u410))
(define-constant ERR_PHASE_TRANSITION_ERROR (err u411))

;; Challenge Categories
(define-constant CATEGORY_SCIENTIFIC u1)
(define-constant CATEGORY_TECHNOLOGICAL u2)
(define-constant CATEGORY_SOCIAL u3)
(define-constant CATEGORY_ENVIRONMENTAL u4)
(define-constant CATEGORY_ECONOMIC u5)
(define-constant CATEGORY_HEALTHCARE u6)

;; Challenge Phases
(define-constant PHASE_CROWD_COLLECTION u1)
(define-constant PHASE_AI_ANALYSIS u2)
(define-constant PHASE_HYBRID_SYNTHESIS u3)
(define-constant PHASE_VALIDATION u4)
(define-constant PHASE_RESOLVED u5)

;; AI Confidence Levels
(define-constant AI_CONFIDENCE_LOW u1)
(define-constant AI_CONFIDENCE_MEDIUM u2)
(define-constant AI_CONFIDENCE_HIGH u3)

;; Data Variables
(define-data-var challenge-counter uint u0)
(define-data-var solution-counter uint u0)
(define-data-var ai-analysis-counter uint u0)
(define-data-var platform-fee-percentage uint u8) ;; 8% platform fee
(define-data-var min-challenge-reward uint u25000) ;; Minimum 25,000 microSTX
(define-data-var crowd-intelligence-threshold uint u5) ;; Minimum contributions before AI analysis
(define-data-var ai-oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; AI Oracle address
(define-data-var reputation-multiplier uint u120) ;; 120% bonus for high reputation contributors

;; Data Maps

;; Innovation Challenge Storage
(define-map innovation-challenges 
    { challenge-id: uint }
    {
        creator: principal,
        title: (string-ascii 128),
        description: (string-ascii 2048),
        category: uint,
        complexity-level: uint,
        reward-pool: uint,
        crowd-contributions: uint,
        ai-analysis-cost: uint,
        current-phase: uint,
        deadline: uint,
        created-at: uint,
        resolved-at: (optional uint),
        winning-solution-id: (optional uint),
        crowd-intelligence-score: uint,
        ai-confidence-level: uint
    }
)

;; Crowd Intelligence Contributions
(define-map crowd-contributions
    { contribution-id: uint, challenge-id: uint }
    {
        contributor: principal,
        contribution-type: uint, ;; 1: insight, 2: data, 3: methodology, 4: validation
        content: (string-ascii 1024),
        relevance-score: uint,
        innovation-factor: uint,
        validated-by-ai: bool,
        validated-by-crowd: bool,
        reputation-weight: uint,
        submitted-at: uint,
        validation-votes: uint
    }
)

;; AI Analysis Results
(define-map ai-analysis
    { analysis-id: uint, challenge-id: uint }
    {
        ai-oracle: principal,
        analysis-summary: (string-ascii 2048),
        confidence-level: uint,
        recommended-approaches: (string-ascii 1024),
        risk-assessment: (string-ascii 512),
        feasibility-score: uint,
        innovation-potential: uint,
        resource-requirements: (string-ascii 512),
        success-probability: uint,
        analyzed-at: uint
    }
)

;; Hybrid Solutions (AI + Crowd Intelligence)
(define-map hybrid-solutions
    { solution-id: uint }
    {
        challenge-id: uint,
        solution-architect: principal,
        title: (string-ascii 128),
        description: (string-ascii 2048),
        implementation-roadmap: (string-ascii 1024),
        crowd-input-integration: (string-ascii 1024),
        ai-enhancement-factor: uint,
        human-creativity-score: uint,
        technical-feasibility: uint,
        market-potential: uint,
        sustainability-index: uint,
        validation-score: uint,
        crowd-votes: uint,
        ai-endorsement: bool,
        submitted-at: uint
    }
)

;; Contributor Profiles
(define-map contributor-profiles
    { contributor: principal }
    {
        name: (string-ascii 64),
        expertise-domains: (string-ascii 256),
        reputation-score: uint,
        contributions-count: uint,
        successful-validations: uint,
        ai-collaboration-rating: uint,
        innovation-index: uint,
        total-rewards-earned: uint,
        last-active: uint
    }
)

;; Validation Votes
(define-map validation-votes
    { solution-id: uint, validator: principal }
    {
        vote-weight: uint,
        expertise-relevance: uint,
        validation-type: uint, ;; 1: technical, 2: feasibility, 3: innovation, 4: market
        vote-rationale: (string-ascii 256),
        voted-at: uint
    }
)

;; Challenge Funding
(define-map challenge-funding
    { challenge-id: uint, funder: principal }
    {
        amount: uint,
        funding-purpose: uint, ;; 1: general reward, 2: AI analysis, 3: validation incentive
        funded-at: uint
    }
)

;; Public Functions

;; Create contributor profile
(define-public (create-contributor-profile
    (name (string-ascii 64))
    (expertise-domains (string-ascii 256)))
    (begin
        (asserts! (> (len name) u0) ERR_INVALID_PARAMETERS)
        (asserts! (> (len expertise-domains) u0) ERR_INVALID_PARAMETERS)
        
        (map-set contributor-profiles { contributor: tx-sender }
            {
                name: name,
                expertise-domains: expertise-domains,
                reputation-score: u75, ;; Starting reputation
                contributions-count: u0,
                successful-validations: u0,
                ai-collaboration-rating: u50,
                innovation-index: u0,
                total-rewards-earned: u0,
                last-active: burn-block-height
            }
        )
        (ok true)
    )
)

;; Post a new innovation challenge
(define-public (post-innovation-challenge
    (title (string-ascii 128))
    (description (string-ascii 2048))
    (category uint)
    (complexity-level uint)
    (reward-amount uint)
    (ai-analysis-budget uint)
    (deadline-blocks uint))
    (let 
        (
            (new-challenge-id (+ (var-get challenge-counter) u1))
            (challenge-deadline (+ burn-block-height deadline-blocks))
            (total-funding (+ reward-amount ai-analysis-budget))
        )
        (asserts! (> (len title) u0) ERR_INVALID_PARAMETERS)
        (asserts! (> (len description) u0) ERR_INVALID_PARAMETERS)
        (asserts! (and (>= category u1) (<= category u6)) ERR_INVALID_PARAMETERS)
        (asserts! (and (>= complexity-level u1) (<= complexity-level u10)) ERR_INVALID_PARAMETERS)
        (asserts! (>= reward-amount (var-get min-challenge-reward)) ERR_INVALID_PARAMETERS)
        (asserts! (>= (stx-get-balance tx-sender) total-funding) ERR_INSUFFICIENT_FUNDS)
        (asserts! (> deadline-blocks u0) ERR_INVALID_PARAMETERS)
        
        ;; Transfer funding to contract
        (try! (stx-transfer? total-funding tx-sender (as-contract tx-sender)))
        
        (map-set innovation-challenges { challenge-id: new-challenge-id }
            {
                creator: tx-sender,
                title: title,
                description: description,
                category: category,
                complexity-level: complexity-level,
                reward-pool: reward-amount,
                crowd-contributions: u0,
                ai-analysis-cost: ai-analysis-budget,
                current-phase: PHASE_CROWD_COLLECTION,
                deadline: challenge-deadline,
                created-at: burn-block-height,
                resolved-at: none,
                winning-solution-id: none,
                crowd-intelligence-score: u0,
                ai-confidence-level: u0
            }
        )
        
        (var-set challenge-counter new-challenge-id)
        (ok new-challenge-id)
    )
)

;; Submit crowd intelligence contribution
(define-public (submit-crowd-contribution
    (challenge-id uint)
    (contribution-type uint)
    (content (string-ascii 1024))
    (relevance-score uint)
    (innovation-factor uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
            (contributor-profile (unwrap! (map-get? contributor-profiles { contributor: tx-sender }) ERR_UNAUTHORIZED))
            (contribution-id (+ (get crowd-contributions challenge) u1))
        )
        (asserts! (is-eq (get current-phase challenge) PHASE_CROWD_COLLECTION) ERR_CHALLENGE_CLOSED)
        (asserts! (<= burn-block-height (get deadline challenge)) ERR_CHALLENGE_CLOSED)
        (asserts! (and (>= contribution-type u1) (<= contribution-type u4)) ERR_INVALID_PARAMETERS)
        (asserts! (> (len content) u0) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= relevance-score u100) (<= innovation-factor u100)) ERR_INVALID_PARAMETERS)
        
        (map-set crowd-contributions { contribution-id: contribution-id, challenge-id: challenge-id }
            {
                contributor: tx-sender,
                contribution-type: contribution-type,
                content: content,
                relevance-score: relevance-score,
                innovation-factor: innovation-factor,
                validated-by-ai: false,
                validated-by-crowd: false,
                reputation-weight: (get reputation-score contributor-profile),
                submitted-at: burn-block-height,
                validation-votes: u0
            }
        )
        
        ;; Update challenge and contributor stats
        (map-set innovation-challenges { challenge-id: challenge-id }
            (merge challenge { 
                crowd-contributions: contribution-id,
                crowd-intelligence-score: (+ (get crowd-intelligence-score challenge) relevance-score)
            })
        )
        
        (map-set contributor-profiles { contributor: tx-sender }
            (merge contributor-profile {
                contributions-count: (+ (get contributions-count contributor-profile) u1),
                last-active: burn-block-height
            })
        )
        
        (ok contribution-id)
    )
)

;; Trigger AI analysis phase
(define-public (trigger-ai-analysis (challenge-id uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
        )
        (asserts! (is-eq (get current-phase challenge) PHASE_CROWD_COLLECTION) ERR_PHASE_TRANSITION_ERROR)
        (asserts! (>= (get crowd-contributions challenge) (var-get crowd-intelligence-threshold)) ERR_INVALID_PARAMETERS)
        (asserts! (or (is-eq tx-sender (get creator challenge)) 
                     (> burn-block-height (- (get deadline challenge) u720))) ERR_UNAUTHORIZED) ;; Creator or 5 days before deadline
        
        (map-set innovation-challenges { challenge-id: challenge-id }
            (merge challenge { current-phase: PHASE_AI_ANALYSIS })
        )
        (ok true)
    )
)

;; Submit AI analysis (called by AI oracle)
(define-public (submit-ai-analysis
    (challenge-id uint)
    (analysis-summary (string-ascii 2048))
    (confidence-level uint)
    (recommended-approaches (string-ascii 1024))
    (risk-assessment (string-ascii 512))
    (feasibility-score uint)
    (innovation-potential uint)
    (resource-requirements (string-ascii 512))
    (success-probability uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
            (new-analysis-id (+ (var-get ai-analysis-counter) u1))
        )
        (asserts! (is-eq tx-sender (var-get ai-oracle-address)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get current-phase challenge) PHASE_AI_ANALYSIS) ERR_PHASE_TRANSITION_ERROR)
        (asserts! (and (>= confidence-level u1) (<= confidence-level u3)) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= feasibility-score u100) (<= innovation-potential u100) (<= success-probability u100)) ERR_INVALID_PARAMETERS)
        
        (map-set ai-analysis { analysis-id: new-analysis-id, challenge-id: challenge-id }
            {
                ai-oracle: tx-sender,
                analysis-summary: analysis-summary,
                confidence-level: confidence-level,
                recommended-approaches: recommended-approaches,
                risk-assessment: risk-assessment,
                feasibility-score: feasibility-score,
                innovation-potential: innovation-potential,
                resource-requirements: resource-requirements,
                success-probability: success-probability,
                analyzed-at: burn-block-height
            }
        )
        
        ;; Update challenge phase and AI confidence
        (map-set innovation-challenges { challenge-id: challenge-id }
            (merge challenge { 
                current-phase: PHASE_HYBRID_SYNTHESIS,
                ai-confidence-level: confidence-level
            })
        )
        
        (var-set ai-analysis-counter new-analysis-id)
        (ok new-analysis-id)
    )
)

;; Submit hybrid solution (combining crowd intelligence + AI insights)
(define-public (submit-hybrid-solution
    (challenge-id uint)
    (title (string-ascii 128))
    (description (string-ascii 2048))
    (implementation-roadmap (string-ascii 1024))
    (crowd-input-integration (string-ascii 1024))
    (ai-enhancement-factor uint)
    (human-creativity-score uint)
    (technical-feasibility uint)
    (market-potential uint)
    (sustainability-index uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
            (contributor-profile (unwrap! (map-get? contributor-profiles { contributor: tx-sender }) ERR_UNAUTHORIZED))
            (new-solution-id (+ (var-get solution-counter) u1))
        )
        (asserts! (is-eq (get current-phase challenge) PHASE_HYBRID_SYNTHESIS) ERR_CHALLENGE_CLOSED)
        (asserts! (<= burn-block-height (get deadline challenge)) ERR_CHALLENGE_CLOSED)
        (asserts! (>= (get reputation-score contributor-profile) u50) ERR_INSUFFICIENT_REPUTATION)
        (asserts! (> (len title) u0) ERR_INVALID_PARAMETERS)
        (asserts! (> (len description) u0) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= ai-enhancement-factor u100) (<= human-creativity-score u100) 
                      (<= technical-feasibility u100) (<= market-potential u100) 
                      (<= sustainability-index u100)) ERR_INVALID_PARAMETERS)
        
        (map-set hybrid-solutions { solution-id: new-solution-id }
            {
                challenge-id: challenge-id,
                solution-architect: tx-sender,
                title: title,
                description: description,
                implementation-roadmap: implementation-roadmap,
                crowd-input-integration: crowd-input-integration,
                ai-enhancement-factor: ai-enhancement-factor,
                human-creativity-score: human-creativity-score,
                technical-feasibility: technical-feasibility,
                market-potential: market-potential,
                sustainability-index: sustainability-index,
                validation-score: u0,
                crowd-votes: u0,
                ai-endorsement: false,
                submitted-at: burn-block-height
            }
        )
        
        ;; Update contributor stats
        (map-set contributor-profiles { contributor: tx-sender }
            (merge contributor-profile { last-active: burn-block-height })
        )
        
        (var-set solution-counter new-solution-id)
        (ok new-solution-id)
    )
)

;; Validate solution (community voting)
(define-public (validate-solution
    (solution-id uint)
    (vote-weight uint)
    (expertise-relevance uint)
    (validation-type uint)
    (vote-rationale (string-ascii 256)))
    (let 
        (
            (solution (unwrap! (map-get? hybrid-solutions { solution-id: solution-id }) ERR_SOLUTION_NOT_FOUND))
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: (get challenge-id solution) }) ERR_CHALLENGE_NOT_FOUND))
            (validator-profile (unwrap! (map-get? contributor-profiles { contributor: tx-sender }) ERR_UNAUTHORIZED))
        )
        (asserts! (or (is-eq (get current-phase challenge) PHASE_HYBRID_SYNTHESIS)
                     (is-eq (get current-phase challenge) PHASE_VALIDATION)) ERR_CHALLENGE_CLOSED)
        (asserts! (not (is-eq tx-sender (get solution-architect solution))) ERR_UNAUTHORIZED)
        (asserts! (and (<= vote-weight u10) (<= expertise-relevance u10) 
                      (>= validation-type u1) (<= validation-type u4)) ERR_INVALID_PARAMETERS)
        (asserts! (is-none (map-get? validation-votes { solution-id: solution-id, validator: tx-sender })) ERR_ALREADY_CONTRIBUTED)
        
        (let 
            (
                (validator-reputation-multiplier (/ (get reputation-score validator-profile) u100))
                (final-vote-weight (* vote-weight expertise-relevance validator-reputation-multiplier))
            )
            (map-set validation-votes { solution-id: solution-id, validator: tx-sender }
                {
                    vote-weight: final-vote-weight,
                    expertise-relevance: expertise-relevance,
                    validation-type: validation-type,
                    vote-rationale: vote-rationale,
                    voted-at: burn-block-height
                }
            )
            
            ;; Update solution validation score
            (map-set hybrid-solutions { solution-id: solution-id }
                (merge solution {
                    validation-score: (+ (get validation-score solution) final-vote-weight),
                    crowd-votes: (+ (get crowd-votes solution) u1)
                })
            )
            
            ;; Update validator stats
            (map-set contributor-profiles { contributor: tx-sender }
                (merge validator-profile {
                    successful-validations: (+ (get successful-validations validator-profile) u1),
                    last-active: burn-block-height
                })
            )
            
            (ok true)
        )
    )
)

;; Resolve challenge and distribute rewards
(define-public (resolve-challenge (challenge-id uint) (winning-solution-id uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
            (winning-solution (unwrap! (map-get? hybrid-solutions { solution-id: winning-solution-id }) ERR_SOLUTION_NOT_FOUND))
            (total-reward (get reward-pool challenge))
            (platform-fee (/ (* total-reward (var-get platform-fee-percentage)) u100))
            (winner-reward (- total-reward platform-fee))
            (winner (get solution-architect winning-solution))
        )
        (asserts! (or (is-eq tx-sender (get creator challenge)) 
                     (> burn-block-height (get deadline challenge))) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get challenge-id winning-solution) challenge-id) ERR_INVALID_PARAMETERS)
        (asserts! (> (get validation-score winning-solution) u50) ERR_INVALID_PARAMETERS) ;; Minimum validation threshold
        
        ;; Distribute rewards
        (try! (as-contract (stx-transfer? winner-reward tx-sender winner)))
        
        ;; Update challenge status
        (map-set innovation-challenges { challenge-id: challenge-id }
            (merge challenge {
                current-phase: PHASE_RESOLVED,
                resolved-at: (some burn-block-height),
                winning-solution-id: (some winning-solution-id)
            })
        )
        
        ;; Update winner's profile
        (let 
            (
                (winner-profile (unwrap! (map-get? contributor-profiles { contributor: winner }) ERR_UNAUTHORIZED))
                (innovation-bonus (if (> (get human-creativity-score winning-solution) u80)
                                    (/ (* winner-reward u25) u100) ;; 25% bonus for high creativity
                                    u0))
            )
            (map-set contributor-profiles { contributor: winner }
                (merge winner-profile {
                    total-rewards-earned: (+ (get total-rewards-earned winner-profile) winner-reward),
                    reputation-score: (+ (get reputation-score winner-profile) u50),
                    innovation-index: (+ (get innovation-index winner-profile) (get human-creativity-score winning-solution))
                })
            )
            
            ;; Transfer innovation bonus if applicable
            (if (> innovation-bonus u0)
                (try! (as-contract (stx-transfer? innovation-bonus tx-sender winner)))
                true
            )
        )
        
        (ok winning-solution-id)
    )
)

;; Add funding to existing challenge
(define-public (fund-challenge (challenge-id uint) (funding-amount uint) (funding-purpose uint))
    (let 
        (
            (challenge (unwrap! (map-get? innovation-challenges { challenge-id: challenge-id }) ERR_CHALLENGE_NOT_FOUND))
        )
        (asserts! (not (is-eq (get current-phase challenge) PHASE_RESOLVED)) ERR_CHALLENGE_CLOSED)
        (asserts! (> funding-amount u0) ERR_INVALID_PARAMETERS)
        (asserts! (>= (stx-get-balance tx-sender) funding-amount) ERR_INSUFFICIENT_FUNDS)
        (asserts! (and (>= funding-purpose u1) (<= funding-purpose u3)) ERR_INVALID_PARAMETERS)
        
        ;; Transfer funding to contract
        (try! (stx-transfer? funding-amount tx-sender (as-contract tx-sender)))
        
        ;; Update challenge reward pool
        (map-set innovation-challenges { challenge-id: challenge-id }
            (merge challenge { reward-pool: (+ (get reward-pool challenge) funding-amount) })
        )
        
        ;; Record funding
        (map-set challenge-funding { challenge-id: challenge-id, funder: tx-sender }
            {
                amount: funding-amount,
                funding-purpose: funding-purpose,
                funded-at: burn-block-height
            }
        )
        (ok true)
    )
)

;; Read-only functions

(define-read-only (get-challenge (challenge-id uint))
    (map-get? innovation-challenges { challenge-id: challenge-id })
)

(define-read-only (get-solution (solution-id uint))
    (map-get? hybrid-solutions { solution-id: solution-id })
)

(define-read-only (get-contributor-profile (contributor principal))
    (map-get? contributor-profiles { contributor: contributor })
)

(define-read-only (get-ai-analysis (analysis-id uint) (challenge-id uint))
    (map-get? ai-analysis { analysis-id: analysis-id, challenge-id: challenge-id })
)

(define-read-only (get-crowd-contribution (contribution-id uint) (challenge-id uint))
    (map-get? crowd-contributions { contribution-id: contribution-id, challenge-id: challenge-id })
)

(define-read-only (get-platform-stats)
    {
        total-challenges: (var-get challenge-counter),
        total-solutions: (var-get solution-counter),
        total-ai-analyses: (var-get ai-analysis-counter),
        platform-fee: (var-get platform-fee-percentage),
        min-challenge-reward: (var-get min-challenge-reward),
        crowd-intelligence-threshold: (var-get crowd-intelligence-threshold)
    }
)

;; Admin functions (contract owner only)
(define-public (update-ai-oracle (new-oracle-address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (var-set ai-oracle-address new-oracle-address)
        (ok true)
    )
)

(define-public (update-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (<= new-fee u15) ERR_INVALID_PARAMETERS) ;; Max 15% fee
        (var-set platform-fee-percentage new-fee)
        (ok true)
    )
)

(define-public (update-crowd-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (var-set crowd-intelligence-threshold new-threshold)
        (ok true)
    )
)