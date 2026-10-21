(define (domain lunar)
    (:requirements :strips :typing :negative-preconditions)

    ; -------------------------------
    ; Types
    ; -------------------------------

    ; EXAMPLE

    ; (:types
    ;     parent_type
    ;     child_type - parent_type

    ; )
    (:types
        Waypoint
        Lander
        Rover

    )

    ; -------------------------------
    ; Predicates
    ; -------------------------------
    ; node_Neighbour - Checks node connections (I.e.: Connected neighbour).
    ; node_HasLander - Checks if current node has the lander.
    ; node_HasRover - Checks if current node has the rover.
    ; node_IsSamplePoint
    ;
    ; lander_HasDropped - Checks if lander has dropped.
    ; lander_HoldingRover - Checks if lander is holding its rover (I.e.: Undeployed rover).
    ; lander_OwnsRover - Checks if lander owns the rover.
    ;
    ; rover_IsDeployed - Checks if rover has been deployed.
    ; rover_HoldingSample - Checks if rover is holding sample
    ; rover_HoldingData - Checks if rover is holding data.
    ;--------------------------------

    (:predicates
        ;Node predicates
        (node_Neighbour ?curNode - Waypoint ?nbNode - Waypoint)
        (node_HasLander ?curNode - Waypoint ?lander - Lander)
        (node_HasRover ?curNode - Waypoint ?rover - Rover)
        (node_HasSamplePoint ?curNode - Waypoint ?targetLander - Lander)
        (node_HasDataPoint ?curNode - Waypoint ?targetLander - Lander)

        ;Lander predicates
        (lander_HasDropped ?lander - Lander)
        (lander_HasUndeployedRover ?lander - Lander)
        (lander_OwnsRover ?lander - Lander ?rover - Rover)

        ;Rover predicates
        (rover_IsDeployed ?rover - Rover)
        (rover_HoldingSample ?rover - Rover)
        (rover_HoldingData ?rover - Rover)
    )

    ; -------------------------------
    ; Actions
    ; lander_Drop
    ;   - Drops lander on a node.
    ;   - Note: Allows multiple lander per node (No node/lander check).
    ; -------------------------------

    ;Lander Actions
    (:action lander_Drop
        :parameters (?lander - Lander ?node - Waypoint)
        :precondition (and 
            (not (lander_HasDropped ?lander))
            )
        :effect (and 
            (lander_HasDropped ?lander) 
            (node_HasLander ?node ?lander)
            )
    )
    (:action lander_DeployRover
        :parameters (?lander - Lander ?rover - Rover ?node - Waypoint)
        :precondition (and 
            (lander_HasUndeployedRover ?lander)     ;Lander has undeployed rover?
            (lander_OwnsRover ?lander ?rover)       ;Lander owns selected rover?
            (node_HasLander ?node ?lander)          ;Lander is on selected node?
            )
        :effect (and 
            (not (lander_HasUndeployedRover ?lander))   ;Lander has no undeployed rovers.
            (node_HasRover ?node ?rover)                ;Node has rover.
            (rover_IsDeployed ?rover)                   ;Rover is deployed.
            )
    )
    
    ;Rover Actions
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
    (:action rover_TakeSample
        :parameters (?rover - Rover ?curNode - Waypoint ?targetLander - Lander)
        :precondition (and 
            (rover_IsDeployed ?rover)                       ;Rover is deployed?
            (node_HasRover ?curNode ?rover)                 ;Rover on current node?
            (node_HasSamplePoint ?curNode ?targetLander)    ;Node has sample point for target lander?
            (lander_OwnsRover ?targetLander ?rover)         ;Lander can receive from rover?
            )
        :effect (and 
            
            )
    )
    
    
)