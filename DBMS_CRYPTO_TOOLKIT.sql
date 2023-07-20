CREATE OR REPLACE NONEDITIONABLE PACKAGE SYS.dbms_crypto_toolkit AS

    SUBTYPE Crypto_Engine_Function IS
        dbms_crypto_toolkit_types.Crypto_Engine_Function;

    DETACHEDSIGNATURE  CONSTANT Crypto_Engine_Function := 1;
                                            -- Signature, detached from content
    SIGNATURE          CONSTANT Crypto_Engine_Function := 2;
                                             -- Signature combined with content
    ENVELOPING         CONSTANT Crypto_Engine_Function := 3;
                                       -- Signature and encryption with content
    PKENCRYPTION       CONSTANT Crypto_Engine_Function := 4;
                                       -- Encryption for one or more recipients
    ENCRYPTION         CONSTANT Crypto_Engine_Function := 5;
                                                        -- Symmetric encryption
    KEYEDHASH_CHECKSUM CONSTANT Crypto_Engine_Function := 6;
                                                         -- Keyed hash/checksum
    HASH_CHECKSUM      CONSTANT Crypto_Engine_Function := 7;   -- Hash/checksum
    RANDOM             CONSTANT Crypto_Engine_Function := 8;
                                                      -- Random byte generation

    SUBTYPE Crypto_Engine_State IS
        dbms_crypto_toolkit_types.Crypto_Engine_State;

    CONTINUE_PROCESSING CONSTANT Crypto_Engine_State := 1;
                                                  -- Continue processing input
    END_PROCESSING      CONSTANT Crypto_Engine_State := 2;
                                                       -- End processing input
    RESET_PROCESSING    CONSTANT Crypto_Engine_State := 3;
                                -- Reset processing and skip generating output

    SUBTYPE Identity_Type IS dbms_crypto_toolkit_types.Identity_Type;

    X509V1    CONSTANT Identity_Type := 1; -- X.509v1
    SYMMETRIC CONSTANT Identity_Type := 2; -- Symmetric

    SUBTYPE Cipher IS dbms_crypto_toolkit_types.Cipher;

    RSA     CONSTANT Cipher := 1; -- RSA public key
    DES     CONSTANT Cipher := 2; -- DES
    RC4     CONSTANT Cipher := 3; -- RC4
    MD5DES  CONSTANT Cipher := 4; -- DES encrypted MD5 with salt (PBE)
    MD5RC2  CONSTANT Cipher := 5; -- RC2 encrypted MD5 with salt (PBE)
    MD5     CONSTANT Cipher := 6; -- MD5
    SHA     CONSTANT Cipher := 7; -- SHA

    SUBTYPE Data_Unit_Format IS dbms_crypto_toolkit_types.Data_Unit_Format;

    PKCS7    CONSTANT Data_Unit_Format := 1; -- PKCS7 format
    RSAPAD   CONSTANT Data_Unit_Format := 2; -- RSA padded format
    ORACLEv1 CONSTANT Data_Unit_Format := 3; -- Oracle v1 format

    package_wallet_is_not_open EXCEPTION;
    PRAGMA EXCEPTION_INIT(package_wallet_is_not_open, -28836);

    package_wallet_is_open EXCEPTION;
    PRAGMA EXCEPTION_INIT(package_wallet_is_open, -28840);

    -- Aliases to reduce typing.
    SUBTYPE Wallet IS dbms_crypto_toolkit_types.Wallet;
    SUBTYPE Persona IS dbms_crypto_toolkit_types.Persona;
    SUBTYPE Identity IS dbms_crypto_toolkit_types.Identity;
    SUBTYPE Identity_Array IS dbms_crypto_toolkit_types.Identity_Array;

    SUBTYPE Alias_String IS dbms_crypto_toolkit_types.Alias_String;
    SUBTYPE Comment_String IS dbms_crypto_toolkit_types.Comment_String;
    SUBTYPE Identity_Description IS
        dbms_crypto_toolkit_types.Identity_Description;
    SUBTYPE Identity_Description_List IS
        dbms_crypto_toolkit_types.Identity_Description_List;
    SUBTYPE Persona_Description IS
        dbms_crypto_toolkit_types.Persona_Description;
    SUBTYPE Persona_List IS dbms_crypto_toolkit_types.Persona_List;
    SUBTYPE Private_Persona_Information IS
        dbms_crypto_toolkit_types.Private_Persona_Information;

    ---------------------- FUNCTIONS AND PROCEDURES ---------------------------
    PROCEDURE Initialize;

    PROCEDURE Terminate;

    PROCEDURE OpenWallet(password                IN     VARCHAR2,
                         wallet                  IN OUT Wallet,
                         persona_list               OUT Persona_List,
                         wallet_resource_locator IN     VARCHAR2 DEFAULT NULL);

    -- Used by applications which want to use the wallet kept by the package.
    PROCEDURE OpenWallet(password                IN     VARCHAR2,
                         persona_list               OUT Persona_List,
                         wallet_resource_locator IN     VARCHAR2 DEFAULT NULL);

    PROCEDURE CloseWallet(wallet IN OUT Wallet);

    -- Used by applications which want to use the wallet kept by the package.
    PROCEDURE CloseWallet;

    PROCEDURE CreateWallet(password              IN     VARCHAR2,
                         wallet                  IN OUT Wallet,
                         wallet_resource_locator IN     VARCHAR2 DEFAULT NULL);

    -- Used by applications which want to use the wallet kept by the package.
    PROCEDURE CreateWallet(password               IN     VARCHAR2,
                         wallet_resource_locator IN     VARCHAR2 DEFAULT NULL);


    PROCEDURE DestroyWallet(password                IN  VARCHAR2,
                            wallet_resource_locator IN  VARCHAR2 DEFAULT NULL);

    PROCEDURE StorePersona(persona IN OUT Persona,
                           wallet  IN OUT Wallet);

    -- Used by applications which want to use the wallet kept by the package.
    PROCEDURE StorePersona(persona IN OUT Persona);

    PROCEDURE OpenPersona(persona IN OUT Persona);

    PROCEDURE ClosePersona(persona IN OUT Persona);

    PROCEDURE RemovePersona(persona IN OUT Persona);

    PROCEDURE CreatePersona(cipher_type         IN     Cipher,
                        private_information IN     Private_Persona_Information,
                        prl                 IN     VARCHAR2,
                        alias               IN     VARCHAR2,
                        longer_description  IN     VARCHAR2,
                        persona                OUT Persona);

    PROCEDURE RemoveIdentity(identity           OUT Identity);

    PROCEDURE CreateIdentity(identitytype       IN     Identity_Type,
                             public_identity    IN     VARCHAR2,
                             alias              IN     VARCHAR2,
                             longer_description IN     VARCHAR2,
                             trust_qualifier    IN     VARCHAR2,
                             identity              OUT Identity);

    PROCEDURE AbortIdentity(identity IN OUT Identity);

    PROCEDURE StoreTrustedIdentity(identity IN OUT Identity,
                                   persona  IN     Persona);

    FUNCTION Validate(persona   IN Persona,
                      identity  IN Identity)
        RETURN BOOLEAN;

    --------------------------- DIGITAL SIGNATURE -----------------------------
    -- The following routines create and verify digital signatures.
    -- There are two versions of each procedure: one for raw data and the
    -- other for strings.
    ---------------------------------------------------------------------------

    PROCEDURE Sign(persona         IN     Persona,
                   input           IN     RAW,
                   signature          OUT RAW,
                   signature_state IN     Crypto_Engine_State
                                   DEFAULT END_PROCESSING);

    FUNCTION Sign(persona         IN Persona,
                  input           IN RAW,
                  signature_state IN Crypto_Engine_State
                                  DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Sign(persona         IN     Persona,
                   input_string       IN     VARCHAR2,
                   signature          OUT RAW,
                   signature_state IN     Crypto_Engine_State
                                   DEFAULT END_PROCESSING);

    FUNCTION Sign(persona         IN     Persona,
                  input_string       IN     VARCHAR2,
                  signature_state IN     Crypto_Engine_State
                                   DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Verify(persona                IN     Persona,
                     signature              IN     RAW,
                     extracted_message         OUT RAW,
                     verified                  OUT BOOLEAN,
                     validated                 OUT BOOLEAN,
                     signing_party_identity    OUT Identity,
                     signature_state        IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Verify(persona                IN     Persona,
                    signature              IN     RAW,
                    verified                  OUT BOOLEAN,
                    validated                 OUT BOOLEAN,
                    signing_party_identity    OUT Identity,
                    signature_state        IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Verify(persona                  IN     Persona,
                     signature                IN     RAW,
                     extracted_message_string    OUT VARCHAR2,
                     verified                    OUT BOOLEAN,
                     validated                   OUT BOOLEAN,
                     signing_party_identity      OUT Identity,
                     signature_state          IN     Crypto_Engine_State
                                              DEFAULT END_PROCESSING);

    FUNCTION Verify(persona                  IN     Persona,
                    signature                IN     RAW,
                    verified                    OUT BOOLEAN,
                    validated                   OUT BOOLEAN,
                    signing_party_identity      OUT Identity,
                    signature_state          IN     Crypto_Engine_State
                                             DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE SignDetached(persona         IN     Persona,
                           input           IN     RAW,
                           signature          OUT RAW,
                           signature_state IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING);

    FUNCTION SignDetached(persona         IN Persona,
                          input           IN RAW,
                          signature_state IN Crypto_Engine_State
                                          DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE SignDetached(persona         IN     Persona,
                           input_string    IN     VARCHAR2,
                           signature          OUT RAW,
                           signature_state IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING);

    FUNCTION SignDetached(persona         IN Persona,
                          input_string    IN VARCHAR2,
                          signature_state IN Crypto_Engine_State
                                          DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE VerifyDetached(persona            IN     Persona,
                         data                   IN     RAW,
                         signature              IN     RAW,
                         verified                  OUT BOOLEAN,
                         validated                 OUT BOOLEAN,
                         signing_party_identity    OUT Identity,
                         signature_state        IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    PROCEDURE VerifyDetached(persona            IN     Persona,
                         data_string            IN     VARCHAR2,
                         signature              IN     RAW,
                         verified                  OUT BOOLEAN,
                         validated                 OUT BOOLEAN,
                         signing_party_identity    OUT Identity,
                         signature_state        IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    ---------------------------- DATA ENCRYPTION ------------------------------
    -- The following routines encrypt and decrypt data.
    -- There are two versions of each procedure: one for raw data and the
    -- other for strings.
    ---------------------------------------------------------------------------

    -- Encrypt for one recipient
    PROCEDURE PKEncrypt(persona          IN     Persona,
                        recipient        IN     Identity,
                        input            IN     RAW,
                        encrypted_data      OUT RAW,
                        encryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKEncrypt(persona          IN Persona,
                       recipient        IN Identity,
                       input            IN RAW,
                       encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE PKEncrypt(persona          IN     Persona,
                        recipient        IN     Identity,
                        input_string     IN     VARCHAR2,
                        encrypted_string    OUT VARCHAR2,
                        encryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKEncrypt(persona          IN Persona,
                       recipient        IN Identity,
                       input_string     IN VARCHAR2,
                       encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE PKEncrypt(persona              IN     Persona,
                        number_of_recipients IN     POSITIVE,
                        recipient_list       IN     Identity_Array,
                        input                IN     RAW,
                        encrypted_data          OUT RAW,
                        encryption_state     IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKEncrypt(persona              IN Persona,
                       number_of_recipients IN POSITIVE,
                       recipient_list       IN Identity_Array,
                       input                IN RAW,
                       encryption_state     IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE PKEncrypt(persona              IN     Persona,
                        number_of_recipients IN     POSITIVE,
                        recipient_list       IN     Identity_Array,
                        input_string         IN     VARCHAR2,
                        encrypted_string        OUT VARCHAR2,
                        encryption_state     IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKEncrypt(persona              IN Persona,
                       number_of_recipients IN POSITIVE,
                       recipient_list       IN Identity_Array,
                       input_string         IN VARCHAR2,
                       encryption_state     IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE PKDecrypt(persona          IN     Persona,
                        input            IN     RAW,
                        decrypted_data      OUT RAW,
                        decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKDecrypt(persona          IN     Persona,
                       input            IN     RAW,
                       decryption_state IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE PKDecrypt(persona          IN     Persona,
                        input_string     IN     VARCHAR2,
                        decrypted_string    OUT VARCHAR2,
                        decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION PKDecrypt(persona          IN Persona,
                       input_string     IN VARCHAR2,
                       decryption_state IN Crypto_Engine_State
                                            DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE Encrypt(persona          IN     Persona,
                      input            IN     RAW,
                      encrypted_data      OUT RAW,
                      encryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Encrypt(persona          IN Persona,
                     input            IN RAW,
                     encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    FUNCTION Encrypt(persona          IN Persona,
                     input_string     IN VARCHAR2,
                     encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE Decrypt(persona          IN     Persona,
                      encrypted_data   IN     RAW,
                      decrypted_data      OUT RAW,
                      decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Decrypt(persona          IN Persona,
                     encrypted_data   IN RAW,
                     decryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Decrypt(persona          IN     Persona,
                      encrypted_string IN     VARCHAR2,
                      decrypted_string    OUT VARCHAR2,
                      decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Decrypt(persona          IN Persona,
                     encrypted_string IN VARCHAR2,
                     decryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    -- Envelope data for one recipient
    PROCEDURE Envelope(persona          IN     Persona,
                       recipient        IN     Identity,
                       input            IN     RAW,
                       enveloped_data      OUT RAW,
                       encryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Envelope(persona          IN Persona,
                      recipient        IN Identity,
                      input            IN RAW,
                      encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Envelope(persona          IN     Persona,
                       recipient        IN     Identity,
                       input_string     IN     VARCHAR2,
                       enveloped_string    OUT VARCHAR2,
                       encryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Envelope(persona          IN Persona,
                      recipient        IN Identity,
                      input_string     IN VARCHAR2,
                      encryption_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE Envelope(persona              IN     Persona,
                       number_of_recipients IN     POSITIVE,
                       recipient_list       IN     Identity_Array,
                       input                IN     RAW,
                       enveloped_data          OUT RAW,
                       encryption_state     IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Envelope(persona              IN Persona,
                      number_of_recipients IN POSITIVE,
                      recipient_list       IN Identity_Array,
                      input                IN RAW,
                      encryption_state     IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Envelope(persona              IN     Persona,
                       number_of_recipients IN     POSITIVE,
                       recipient_list       IN     Identity_Array,
                       input_string         IN     VARCHAR2,
                       enveloped_string        OUT VARCHAR2,
                       encryption_state     IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Envelope(persona              IN Persona,
                      number_of_recipients IN POSITIVE,
                      recipient_list       IN Identity_Array,
                      input_string         IN VARCHAR2,
                      encryption_state     IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    PROCEDURE DeEnvelope(persona          IN     Persona,
                         enveloped_data   IN     RAW,
                         output_data         OUT RAW,
                         verified            OUT BOOLEAN,
                         validated           OUT BOOLEAN,
                         sender_identity     OUT Identity,
                         decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION DeEnvelope(persona          IN     Persona,
                        enveloped_data   IN     RAW,
                        verified            OUT BOOLEAN,
                        validated           OUT BOOLEAN,
                        sender_identity     OUT Identity,
                        decryption_state IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE DeEnvelope(persona          IN     Persona,
                         enveloped_string IN     VARCHAR2,
                         output_string       OUT VARCHAR2,
                         verified            OUT BOOLEAN,
                         validated           OUT BOOLEAN,
                         sender_identity     OUT Identity,
                         decryption_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION DeEnvelope(persona          IN     Persona,
                        enveloped_string IN     VARCHAR2,
                        verified            OUT BOOLEAN,
                        validated           OUT BOOLEAN,
                        sender_identity     OUT Identity,
                        decryption_state IN     Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN VARCHAR2;

    --------------------------------- HASH ------------------------------------
    -- The following routines generate checksums.
    -- There are two versions of each procedure: one for raw data and the
    -- other for strings.
    ---------------------------------------------------------------------------
    PROCEDURE KeyedHash(persona    IN     Persona,
                        input      IN     RAW,
                        keyed_hash    OUT RAW,
                        hash_state IN     Crypto_Engine_State
                                          DEFAULT END_PROCESSING);

    FUNCTION KeyedHash(persona    IN Persona,
                       input      IN RAW,
                       hash_state IN Crypto_Engine_State
                                         DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE KeyedHash(persona      IN     Persona,
                        input_string IN     VARCHAR2,
                        keyed_hash      OUT RAW,
                        hash_state   IN     Crypto_Engine_State
                                          DEFAULT END_PROCESSING);

    FUNCTION KeyedHash(persona      IN Persona,
                       input_string IN VARCHAR2,
                       hash_state   IN Crypto_Engine_State
                                         DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Hash(persona    IN     Persona,
                   input      IN     RAW,
                   hash          OUT RAW,
                   hash_state IN     Crypto_Engine_State
                                            DEFAULT END_PROCESSING);

    FUNCTION Hash(persona    IN Persona,
                  input      IN RAW,
                  hash_state IN Crypto_Engine_State
                                           DEFAULT END_PROCESSING)
        RETURN RAW;

    PROCEDURE Hash(persona      IN     Persona,
                   input_string IN     VARCHAR2,
                   hash            OUT RAW,
                   hash_state   IN     Crypto_Engine_State
                                              DEFAULT END_PROCESSING);

    FUNCTION Hash(persona      IN Persona,
                  input_string IN VARCHAR2,
                  hash_state   IN Crypto_Engine_State
                                             DEFAULT END_PROCESSING)
        RETURN RAW;

    ----------------------------- RANDOM NUMBER -------------------------------
    PROCEDURE SeedRandom(persona IN Persona,
                         seed    IN RAW);

    PROCEDURE SeedRandom(persona IN Persona,
                         seed    IN VARCHAR2);

    PROCEDURE SeedRandom(persona IN Persona,
                         seed    IN BINARY_INTEGER);

    PROCEDURE RandomBytes(persona                 IN     Persona,
                          number_of_bytes_desired IN     POSITIVE,
                          random_bytes               OUT RAW);

    FUNCTION RandomBytes(persona                 IN Persona,
                         number_of_bytes_desired IN POSITIVE)
        RETURN RAW;

    PROCEDURE RandomNumber(persona       IN     Persona,
                           random_number    OUT BINARY_INTEGER);

    FUNCTION RandomNumber(persona IN Persona)
        RETURN BINARY_INTEGER;

    PRAGMA RESTRICT_REFERENCES(DEFAULT, WNDS, RNDS);

END dbms_crypto_toolkit;
