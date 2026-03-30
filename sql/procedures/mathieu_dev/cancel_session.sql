DELIMITER //

CREATE PROCEDURE CancelSession(
    IN p_SessionID BINARY(16)
)
BEGIN
    DECLARE v_SessionStatus VARCHAR(20);
    DECLARE v_RowCount INT;

    -- Check if session ID is NULL
    IF p_SessionID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: SessionID cannot be NULL';
    END IF;

    -- Check if session exists and get its current status
    SELECT Status INTO v_SessionStatus
    FROM Session
    WHERE SessionID = p_SessionID;

    IF v_SessionStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session not found';
    END IF;

    -- Check if session is already cancelled or completed
    IF v_SessionStatus = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session is already cancelled';
    END IF;

    IF v_SessionStatus = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot cancel a completed session';
    END IF;

    -- Update session status to Cancelled
    UPDATE Session
    SET Status = 'Cancelled'
    WHERE SessionID = p_SessionID;

    SELECT 'Session cancelled successfully' AS Message;
END //

DELIMITER ;
