CREATE OR REPLACE NONEDITIONABLE PACKAGE SYS.dbms_obfuscation_toolkit AS

    -- Note that the following pragma applies to both functions
    -- and procedures (see doc bug 3103959).
    pragma restrict_references (default, RNDS, WNDS, RNPS, WNPS);

    ------------------------------- TYPES ------------------------------------
    -- Types used to make it easier for the user to reserve the correct
    -- amount of memory for a checksum.

    SUBTYPE varchar2_checksum IS VARCHAR2(16);
    SUBTYPE raw_checksum IS RAW(16);

    ----------------------------- CONSTANTS -----------------------------------
    -- Triple DES modes
    TwoKeyMode   CONSTANT INTEGER := 0;
    ThreeKeyMode CONSTANT INTEGER := 1;

    ----------------------------- EXCEPTIONS ----------------------------------
    -- Invalid mode specified for Triple DES.
    InvalidTripleDESMode EXCEPTION;
    PRAGMA EXCEPTION_INIT(InvalidTripleDESMode, -28236);

    ---------------------- FUNCTIONS AND PROCEDURES ---------------------------

    ---------------------------- KEY GENERATION ------------------------------
    -- The following routines generate encryption keys. Each takes a random
    -- value which it uses in the generation of the key. This value must be
    -- at least 80 characters long.
    -- There are two versions of each procedure and function: one for raw data
    -- and the other for strings.
    ---------------------------------------------------------------------------
    PROCEDURE DESGetKey(seed  IN     RAW,
                        key      OUT RAW);
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    FUNCTION DESGetKey(seed IN RAW) RETURN RAW;
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    PROCEDURE DESGetKey(seed_string IN     VARCHAR2,
                        key            OUT VARCHAR2);
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    FUNCTION DESGetKey(seed_string IN VARCHAR2) RETURN VARCHAR2;
    pragma restrict_references (DESGetKey, RNDS, WNDS, WNPS);

    -- For Triple DES, the mode is specified so that the key has the proper
    -- length is returned.
    PROCEDURE DES3GetKey(which IN     PLS_INTEGER DEFAULT TwoKeyMode,
                         seed  IN     RAW,
                         key      OUT RAW);
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    FUNCTION DES3GetKey(which IN PLS_INTEGER DEFAULT TwoKeyMode,
                        seed  IN RAW)
        RETURN RAW;
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    PROCEDURE DES3GetKey(which       IN     PLS_INTEGER DEFAULT TwoKeyMode,
                         seed_string IN     VARCHAR2,
                         key            OUT VARCHAR2);
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    FUNCTION DES3GetKey(which        IN PLS_INTEGER DEFAULT TwoKeyMode,
                        seed_string  IN VARCHAR2)
        RETURN VARCHAR2;
    pragma restrict_references (DES3GetKey, RNDS, WNDS, WNPS);

    ---------------------------- DATA ENCRYPTION ------------------------------
    -- The following routines encrypt and decrypt data.
    -- There are two versions of each procedure and function: one for raw data
    -- and the other for strings.
    ---------------------------------------------------------------------------

    -- DES
    PROCEDURE DESEncrypt(input            IN     RAW,
                         key              IN     RAW,
                         encrypted_data      OUT RAW);

    FUNCTION DESEncrypt(input            IN  RAW,
                        key              IN  RAW)
        RETURN RAW;

    PROCEDURE DESEncrypt(input_string    IN     VARCHAR2,
                        key_string       IN     VARCHAR2,
                        encrypted_string    OUT VARCHAR2);

    FUNCTION DESEncrypt(input_string     IN  VARCHAR2,
                        key_string       IN  VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE DESDecrypt(input            IN      RAW,
                         key              IN      RAW,
                         decrypted_data       OUT RAW);

    FUNCTION DESDecrypt(input            IN  RAW,
                        key              IN  RAW)
        RETURN RAW;

    PROCEDURE DESDecrypt(input_string     IN    VARCHAR2,
                         key_string       IN    VARCHAR2,
                         decrypted_string    OUT VARCHAR2);

    FUNCTION DESDecrypt(input_string     IN     VARCHAR2,
                        key_string       IN  VARCHAR2)
        RETURN VARCHAR2;

    -- Triple DES

    PROCEDURE DES3Encrypt(input          IN     RAW,
                          key            IN     RAW,
                          encrypted_data    OUT RAW,
                          which          IN     PLS_INTEGER
                                                  DEFAULT TwoKeyMode,
                          iv             IN     RAW DEFAULT NULL);
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Encrypt(input IN RAW,
                         key   IN RAW,
                         which IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv    IN RAW DEFAULT NULL)
        RETURN RAW;
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Encrypt(input_string     IN     VARCHAR2,
                          key_string       IN     VARCHAR2,
                          encrypted_string    OUT VARCHAR2,
                          which            IN     PLS_INTEGER
                                                    DEFAULT TwoKeyMode,
                          iv_string        IN     VARCHAR2 DEFAULT NULL);
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Encrypt(input_string  IN VARCHAR2,
                         key_string    IN VARCHAR2,
                         which         IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv_string     IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;
    pragma restrict_references (DES3Encrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Decrypt(input          IN     RAW,
                          key            IN     RAW,
                          decrypted_data    OUT RAW,
                          which          IN     PLS_INTEGER
                                                  DEFAULT TwoKeyMode,
                          iv             IN     RAW DEFAULT NULL);
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Decrypt(input IN RAW,
                         key   IN RAW,
                         which IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv    IN RAW DEFAULT NULL)
        RETURN RAW;
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    PROCEDURE DES3Decrypt(input_string     IN     VARCHAR2,
                          key_string       IN     VARCHAR2,
                          decrypted_string    OUT VARCHAR2,
                          which            IN     PLS_INTEGER
                                                    DEFAULT TwoKeyMode,
                          iv_string        IN VARCHAR2 DEFAULT NULL);
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    FUNCTION DES3Decrypt(input_string IN VARCHAR2,
                         key_string   IN VARCHAR2,
                         which        IN PLS_INTEGER DEFAULT TwoKeyMode,
                         iv_string    IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;
    pragma restrict_references (DES3Decrypt, RNDS, WNDS, WNPS);

    -------------------------------- MD5 --------------------------------------
    -- The following routines generate MD5 hashes of data.
    -- There are two versions: one for raw data and the other for strings.
    ---------------------------------------------------------------------------

    PROCEDURE MD5(input    IN  RAW,
                  checksum OUT raw_checksum);

    FUNCTION MD5(input    IN  RAW)
        RETURN raw_checksum;

    PROCEDURE MD5(input_string    IN     VARCHAR2,
                  checksum_string    OUT varchar2_checksum);

    FUNCTION MD5(input_string    IN     VARCHAR2)
        RETURN varchar2_checksum;

END dbms_obfuscation_toolkit;
