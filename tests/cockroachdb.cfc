component extends="org.lucee.cfml.test.LuceeTestCase" labels="cockroachdb" {

	function beforeAll (){
		variables.bundleName = "cockroachdb-jdbc";
		if ( _isConfEmpty() ) {
			systemOutput( "CockroachDB environment variables not set, skipping tests", true );
			return;
		}
		variables.conf = _getCockroachEnvVars();
		variables.ds = {
			class: "io.cockroachdb.jdbc.CockroachDriver"
	//		, bundleName: bundleName
	//		, bundleVersion: bundleVersion
			 , connectionString: "jdbc:cockroachdb://#variables.conf.host#:#variables.conf.port#/#variables.conf.database#?sslmode=disable"
			, username: variables.conf.username
			// In insecure mode, omit password to avoid authentication issues
		};
	}

	function run(){
		describe( title="CockroachDB basic connection test", body=function(){

			it("expect config to not be empty", function(){
				expect( _getCockroachEnvVars() ).notToBeEmpty("cockroachdb environment variables not set");
			});

			it(title="verify cockroachdb with dbinfo", skip=_isConfEmpty(), body=function(){
				dbinfo datasource="#ds#" name="local.result" type="version";
				systemOutput( "", true );
				systemOutput( ds, true );
				systemOutput( local.result.toJson(), true );
				expect( local.result ).notToBeEmpty();
			});

		});

		describe( title="CockroachDB basic CRUD tests", body=function(){
			it(title="can create a table", skip=_isConfEmpty(), body=function(){
				// Clean up any existing test data first
				QueryExecute( "DROP TABLE IF EXISTS test_table", {}, {datasource=ds} );
				var sql = "CREATE TABLE test_table (id INT PRIMARY KEY, name VARCHAR(255))";
				var result = QueryExecute( sql, {}, {datasource=ds} );
				expect( result ).toBeQuery();
			});
			it(title="can insert a row", skip=_isConfEmpty(), body=function(){
				var sql = "INSERT INTO test_table (id, name) VALUES (?, ?)";
				var params = [1, "Alice"];
				var result = QueryExecute( sql, params, {datasource=ds} );
				expect( result ).toBeQuery();
			});
			it(title="can select a row", skip=_isConfEmpty(), body=function(){
				var sql = "SELECT * FROM test_table WHERE id = ?";
				var params = [{value=1, cfsqltype="CF_SQL_INTEGER"}];
				var result = QueryExecute( sql, params, {datasource=ds} );
				expect( result.recordCount ).toBe( 1 );
				expect( result.name ).toBe( "Alice" );
			});
			it(title="can update a row", skip=_isConfEmpty(), body=function(){
				var sql = "UPDATE test_table SET name = ? WHERE id = ?";
				var params = ["Bob", {value=1, cfsqltype="CF_SQL_INTEGER"}];
				var result = QueryExecute( sql, params, {datasource=ds} );
				expect( result ).toBeQuery();
				// Verify update
				var verify = QueryExecute( "SELECT * FROM test_table WHERE id = ?", [{value=1, cfsqltype="CF_SQL_INTEGER"}], {datasource=ds} );
				expect( verify.name ).toBe( "Bob" );
			});
			it(title="can delete a row", skip=_isConfEmpty(), body=function(){
				var sql = "DELETE FROM test_table WHERE id = ?";
				var params = [{value=1, cfsqltype="CF_SQL_INTEGER"}];
				var result = QueryExecute( sql, params, {datasource=ds} );
				expect( result ).toBeQuery();
				// Verify delete
				var verify = QueryExecute( "SELECT * FROM test_table WHERE id = ?", [{value=1, cfsqltype="CF_SQL_INTEGER"}], {datasource=ds} );
				expect( verify.recordCount ).toBe( 0 );
			});
			
		})
	}

	private boolean function _isConfEmpty() {
		return isEmpty(_getCockroachEnvVars());
	}

	private struct function _getCockroachEnvVars() {
		return server._getSystemPropOrEnvVars("HOST,USERNAME,PORT,DATABASE", "COCKROACHDB_");
	}

}
