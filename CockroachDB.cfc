component extends="types.Driver" output="no" implements="types.IDatasource" {

    fields = array(
        field("SSL Mode", "sslmode", "disable,require,verify-ca,verify-full", "disable", "SSL mode to use for the connection.", "radio"),
        field("Application Name", "application_name", "", false, "Optional application name for the connection."),
        field("Timezone", "timezone", "", false, "Set the session timezone for the connection."),
        field("Retry Transient Errors", "retryTransientErrors", "true,false", "false", "Automatically retry serialization failures during transactions.", "radio"),
        field("Implicit SELECT FOR UPDATE", "implicitSelectForUpdate", "true,false", "false", "Automatically append FOR UPDATE to qualified SELECT statements to reduce contention.", "radio"),
        field("Rewrite Batched Inserts", "reWriteBatchedInserts", "true,false", "false", "Enable array-based rewrites for bulk INSERT operations.", "radio"),
        field("Rewrite Batched Updates", "reWriteBatchedUpdates", "true,false", "false", "Enable array-based rewrites for bulk UPDATE operations.", "radio"),
        field("Rewrite Batched Upserts", "reWriteBatchedUpserts", "true,false", "false", "Enable array-based rewrites for bulk UPSERT operations.", "radio"),
        field("Retry Max Attempts", "retryMaxAttempts", "", "15", "Maximum number of retry attempts for transient errors (default: 15)."),
        field("Retry Max Backoff Time", "retryMaxBackoffTime", "", "30s", "Maximum backoff time between retries (default: 30s).")
    );

    this.type.port = this.TYPE_FREE;
    this.value.host = "localhost";
    this.value.port = 26257;
    this.className = "{class-name}";
    this.bundleName = "{bundle-name}";
    this.dsn = "{connString}";

    /**
    * Custom parameter syntax for CockroachDB JDBC URLs
    */
    public struct function customParameterSyntax() {
        return {leadingdelimiter:'?', delimiter:'&', separator:'='};
    }

    /**
    * Validate field combinations before saving
    */
    public void function onBeforeUpdate() {
        // Validate retry settings
        if (len(form.custom_retryMaxAttempts ?: "")) {
            var attempts = val(form.custom_retryMaxAttempts);
            if (attempts < 1 || attempts > 100) {
                throw message="Retry Max Attempts must be between 1 and 100";
            }
        }

        // Validate backoff time format
        if (len(form.custom_retryMaxBackoffTime ?: "")) {
            var backoffTime = form.custom_retryMaxBackoffTime;
            if (!reFindNoCase("^\d+[smh]?$", backoffTime)) {
                throw message="Retry Max Backoff Time must be in format like '30s', '5m', or '1h'";
            }
        }
    }

    /**
    * returns display name of the driver
    */
    public string function getName() {
        return "{label}";
    }

    /**
    * returns the id of the driver
    */
    public string function getId() {
        return "{id}";
    }

    /**
    * returns the description of the driver
    */
    public string function getDescription() {
        return "{description}";
    }

    /**
    * returns array of fields
    */
    public array function getFields() {
        return fields;
    }

    public boolean function literalTimestampWithTSOffset() {
        return false;
    }

    public boolean function alwaysSetTimeout() {
        return true;
    }
}