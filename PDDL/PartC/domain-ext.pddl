(define (domain lunar)
    (:requirements :strips :typing :negative-preconditions)

    ; -------------------------------
    ; Types
    ; -------------------------------

    ; )
    (:types
        Waypoint
        Lander
        Rover
        Sample
        Data
        Astronaut
    )

;====================================================================================================

; > Predicates

; node_Neighbour - Node connections (I.e.: Connected neighbour).
; node_HasLander - Node has a lander.
; node_HasRover - Node has a rover.
; node_HasSample - Node holds a sample.
; node_HasData - Node holds data.

; lander_HasDropped - Checks if lander has dropped.
; lander_HoldingRover - Checks if lander is holding its rover (I.e.: Undeployed rover).
; lander_OwnsRover - Checks if lander owns the rover.
; lander_HasSample - Checks what sample the lander is holding.
; lander_HasData - Checks what data the lander is holding.
; lander_IsHoldingSample - Checks if the lander is holding a sample (Restricts lander held sample to 1).

; rover_IsDeployed - Checks if rover has been deployed.
; rover_HasSample - Checks what sample the rover is holding.
; rover_HasData - Checks what data the rover is holding.
; rover_IsHoldingSample - Checks if the rover is holding a sample.
; rover_IsHoldingData - Checks if the rover is holding data.

; sample_TargetLander - Sample's target lander.
; data_TargetLander - Data's target lander. 

; astr_ExistsForLander - Checks if an astronaut exists for a lander.
; astr_InLander - Holds astronaut-lander relation.
; astr_InControlRoom - Checks if astronaut is in the control room.
; astr_InDockingBay - Checks if the astronaut is in the docking bay.
;====================================================================================================

    (:predicates
        ;Node predicates
        (node_Neighbour ?curNode - Waypoint ?nbNode - Waypoint)
        (node_HasLander ?curNode - Waypoint ?lander - Lander)
        (node_HasRover ?curNode - Waypoint ?rover - Rover)
        (node_HasSample ?curNode - Waypoint ?sample - Sample)
        (node_HasData ?curNode - Waypoint ?data - Data)

        ;Lander predicates
        (lander_HasDropped ?lander - Lander)
        (lander_HasUndeployedRover ?lander - Lander)
        (lander_OwnsRover ?lander - Lander ?rover - Rover)
        (lander_HasSample ?lander - Lander ?sample - Sample)
        (lander_HasData ?lander - Lander ?data - Data)
        (lander_IsHoldingSample ?lander - Lander)

        ;Rover predicates
        (rover_IsDeployed ?rover - Rover)
        (rover_HasSample ?rover - Rover ?sample - Sample)
        (rover_HasData ?rover - Rover ?data - Data)
        (rover_IsHoldingSample ?rover - Rover)
        (rover_IsHoldingData ?rover - Rover)

        ;Sample/Data Predicates
        (sample_TargetLander ?sample - Sample ?lander - Lander)
        (data_TargetLander ?data - Data ?lander - Lander)

        ;Astronaut Predicates
        (astr_ExistsForLander ?lander)
        (astr_InLander ?astr - Astronaut ?lander - Lander)
        (astr_InControlRoom ?astr - Astronaut)
        (astr_InDockingBay ?astr - Astronaut)
    )

;====================================================================================================

; > Actions

; lander_Drop - Drops lander on a node.
; lander_DeployRover - Deploys rover from lander.

; rover_Move - Moves the rover from one node to another connected node.
; rover_TakeSample - Rover picks up a sample.
; rover_TakeData - Rover picks up data.
; rover_SubmitSample - Legacy Submit. Rover submits sample to lander.
; rover_SubmitData - Legacy Submit. Rover submits data to lander.
; rover_SubmitSampleAstr - Astr Submit. Rover submits sample to lander with astronaut.
; rover_SubmitDataAstr - Astr Submit. Rover submits data to lander with astronaut.

; astr_Move_ToControlRoom - Astronaut moves to control room.
; astr_Move_ToDockingBay - Astronaut moves to docking bay.

;====================================================================================================

    ;Lander Actions
    ;------------------------------------------------------------------------------------------------
    (:action lander_Drop
        :parameters (?lander - Lander ?node - Waypoint)
        :precondition (and 
            (not (lander_HasDropped ?lander))   ;Lander is not dropped?
            )
        :effect (and 
            (lander_HasDropped ?lander)     ;Lander is dropped.
            (node_HasLander ?node ?lander)  ;Node has lander.
            )
    )
    (:action lander_DeployRover
        :parameters (?lander - Lander ?rover - Rover ?node - Waypoint)
        :precondition (and 
            (lander_HasDropped ?lander)             ;Lander has been dropped?
            (lander_HasUndeployedRover ?lander)     ;Lander has undeployed rover?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns rover?
            (node_HasLander ?node ?lander)          ;Lander is on node?
            )
        :effect (and 
            (not (lander_HasUndeployedRover ?lander))   ;Lander has no undeployed rovers.
            (node_HasRover ?node ?rover)                ;Node has rover.
            (rover_IsDeployed ?rover)                   ;Rover is deployed.
            )
    )
    
    ;Rover Actions
    ;--- [Movement] ---------------------------------------------------------------------------------------------
    (:action rover_Move
        :parameters (?rover - Rover ?curNode - Waypoint ?targetNode - Waypoint)
        :precondition (and 
            (rover_IsDeployed ?rover)               ;Rover is deployed?
            (node_HasRover ?curNode ?rover)         ;Rover on current node?
            (node_Neighbour ?curNode ?targetNode)   ;Node is connected to target node?
            )
        :effect (and 
            (not (node_HasRover ?curNode ?rover))   ;Prev node does not have rover.
            (node_HasRover ?targetNode ?rover)      ;New node has rover.
            )
    )
    ;--- [Take] ---------------------------------------------------------------------------------------------
    (:action rover_TakeSample
        :parameters (?rover - Rover ?curNode - Waypoint ?sample - Sample ?targetLander - Lander)
        :precondition (and 
            (rover_IsDeployed ?rover)                       ;Rover is deployed?
            (not (rover_IsHoldingSample ?rover))            ;Rover already has a sample held?
            (node_HasRover ?curNode ?rover)                 ;Rover on current node?
            (node_HasSample ?curNode ?sample)               ;Node has sample?
            (sample_TargetLander ?sample ?targetLander)     ;Sample is for target lander? 
            (lander_OwnsRover ?targetLander ?rover)         ;Lander can receive from rover?
            )
        :effect (and 
            (not (node_HasSample ?curNode ?sample))     ;Node does not have sample.
            (rover_HasSample ?rover ?sample)            ;Rover has sample.
            (rover_IsHoldingSample ?rover)              ;Rover is holding sample.
            )
    )
    (:action rover_TakeData
        :parameters (?rover - Rover ?curNode - Waypoint ?data - Data ?targetLander - Lander)
        :precondition (and 
            (rover_IsDeployed ?rover)                   ;Rover is deployed?
            (not (rover_IsHoldingData ?rover))          ;Rover already has data held?
            (node_HasRover ?curNode ?rover)             ;Rover on current node?
            (node_HasData ?curNode ?data)               ;Node has data for target lander?
            (data_TargetLander ?data ?targetLander)     ;Data is for target lander?
            (lander_OwnsRover ?targetLander ?rover)     ;Lander can receive from rover?
            )
        :effect (and 
            (not (node_HasData ?curNode ?data))     ;Node does not have data.
            (rover_HasData ?rover ?data)            ;Rover has data.
            (rover_IsHoldingData ?rover)            ;Rover is holding data.
            )
    )
    ;--- [Legacy Submit] ---------------------------------------------------------------------------------------------
    (:action rover_SubmitSample
        :parameters (?rover - Rover ?curNode - Waypoint ?sample - Sample ?lander - Lander)
        :precondition (and 
            (rover_IsDeployed ?rover)               ;Rover is deployed?
            (rover_HasSample ?rover ?sample)        ;Rover has a sample?
            (node_HasRover ?curNode ?rover)         ;Rover on current node?
            (node_HasLander ?curNode ?lander)       ;Node has lander?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns rover?
            (not (lander_IsHoldingSample ?lander))
            (sample_TargetLander ?sample ?lander)   ;Sample is for target lander?

            (not (astr_ExistsForLander ?lander))    ;Astronaut not exist for this lander?
            )
        :effect (and 
            (not (rover_HasSample ?rover ?sample))  ;Rover has no sample.
            (not (rover_IsHoldingSample ?rover))    ;Rover is not holding a sample.
            (lander_HasSample ?lander ?sample)      ;Lander has the sample.
            (lander_IsHoldingSample ?lander)        ;Lander is holding a sample.
            )
    )
    (:action rover_SubmitData
        :parameters (?rover - Rover ?data - Data ?lander - Lander)
        :precondition (and 
            (rover_IsDeployed ?rover)               ;Rover is deployed?
            (rover_HasData ?rover ?data)            ;Rover has data?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns rover?
            (data_TargetLander ?data ?lander)       ;Data is for target lander?

            (not (astr_ExistsForLander ?lander))    ;Astronaut not exist for this lander?
            )
        :effect (and 
            (not (rover_HasData ?rover ?data))  ;Rover has no data.
            (not (rover_IsHoldingData ?rover))  ;Rover is not holding data.
            (lander_HasData ?lander ?data)      ;Lander has the data.
            )
    )
    ;--- [Astr Submit] ---------------------------------------------------------------------------------------------
    (:action rover_SubmitSampleAstr
        :parameters (?rover - Rover ?curNode - Waypoint ?sample - Sample ?lander - Lander ?astr - Astronaut)
        :precondition (and 
            (rover_IsDeployed ?rover)               ;Rover is deployed?
            (rover_HasSample ?rover ?sample)        ;Rover has a sample?
            (node_HasRover ?curNode ?rover)         ;Rover on current node?
            (node_HasLander ?curNode ?lander)       ;Node has lander?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns rover?
            (not (lander_IsHoldingSample ?lander))
            (sample_TargetLander ?sample ?lander)   ;Sample is for target lander?

            (astr_InLander ?astr ?lander)           ;Astronaut is in this lander?
            (astr_ExistsForLander ?lander)          ;Astronaut exists for this lander?
            (astr_InDockingBay ?astr)               ;Astronaut is in the docking bay?
            )
        :effect (and 
            (not (rover_HasSample ?rover ?sample))  ;Rover has no sample.
            (not (rover_IsHoldingSample ?rover))    ;Rover is not holding a sample.
            (lander_HasSample ?lander ?sample)      ;Lander has the sample.
            (lander_IsHoldingSample ?lander)        ;Lander is holding a sample.
            )
    )
    (:action rover_SubmitDataAstr
        :parameters (?rover - Rover ?data - Data ?lander - Lander ?astr - Astronaut)
        :precondition (and 
            (rover_IsDeployed ?rover)               ;Rover is deployed?
            (rover_HasData ?rover ?data)            ;Rover has data?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns rover?
            (data_TargetLander ?data ?lander)       ;Data is for target lander?

            (astr_InLander ?astr ?lander)           ;Astronaut is in this lander?
            (astr_ExistsForLander ?lander)          ;Astronaut exists for this lander?
            (astr_InControlRoom ?astr)              ;Astronaut is in the control room?
            )
        :effect (and 
            (not (rover_HasData ?rover ?data))  ;Rover has no data.
            (not (rover_IsHoldingData ?rover))  ;Rover is not holding data.
            (lander_HasData ?lander ?data)      ;Lander has the data.
            )
    )

    ;Astronaut Actions
    ;------------------------------------------------------------------------------------------------
    (:action astr_Move_ToControlRoom
        :parameters (?astr - Astronaut)
        :precondition (and 
            (astr_InDockingBay ?astr)           ;Astr in docking bay?
            (not (astr_InControlRoom ?astr))    ;Astr not in control room?
            )
        :effect (and 
            (not(astr_InDockingBay ?astr))      ;Astr not in docking bay.
            (astr_InControlRoom ?astr)          ;Astr in control room.
            )
    )
    (:action astr_Move_ToDockingBay
        :parameters (?astr - Astronaut)
        :precondition (and 
            (not (astr_InDockingBay ?astr))     ;Astr not in docking bay?
            (astr_InControlRoom ?astr)          ;Astr in control room?
            )
        :effect (and 
            (astr_InDockingBay ?astr)           ;Astr in docking bay.
            (not (astr_InControlRoom ?astr))    ;Astr not in control room.
            )
    )
    
    
)