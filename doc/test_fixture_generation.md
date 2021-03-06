# Test Fixture Generation

## Plain Ontology Fixtures
In the `spec/fixtures/ontologies` directory, we store the ontology files which we use for testing.

## Fixtures generated by Hets
### Ontologies
Ontohub evaluates ontologies by HTTP interaction with Hets, i.e. first an ontology file is read,
then an HTTP request is sent to Hets to analyze the ontology and
Ontohub evaluates this response to store ontology objects in the database.

In the tests, we use recordings of Hets' HTTP responses.
Those are generated by the rake task `test:freshen_ontology_fixtures`.
This task recreates the fixtures that are out of date, i.e. older than the Hets installation.

### Provers, Proof and ProveOptions
Proving also is accomplished by HTTP interaction with Hets and
the tests around proving use recordings of such interaction as well.
Those recordings can be created with the rake tasks `test:freshen_provers_fixtures`,
`test:freshen_proofs_fixtures` and `test:freshen_prover_output_fixtures`.
Those tasks update the outdated fixtures just like the one for ontologies.
Only proving with *default options* is supported for the predefined fixtures.

### Common Rake Task
All the above-mentioned fixtures can be generated with a single task:
`test:freshen_fixtures`.
This task also only recreates the fixtures that need to be updated.

### Fixture Generation Procedure
All those tasks require Hets to run.
If the Hets server is not listening on port 8000, one will be started for the
time of the fixture generation.
This is done in the `FixturesGeneration::DirectHetsGenerator` class and its children.

### Proving with non-default options
When we test proving with non-default options, we don't use fixtures that are generated beforehand,
but some that are generated *during* the test.
This is because we don't know which options we want to pass to Hets without loading the tests.
The test itself now needs to generate fixtures for the whole evaluation pipeline
consisting of importing ontologies and proving its theorems.

This is where the `FixtureGeneration::PipelineGenerator` class is useful.
When using its `with_cassete` method, first it tries to find a recording of the HTTP interaction.
If there is none, it starts the Hets and Rails servers (if not already running) and records this interaction while executing the test code.
In the end, the servers are shut down again (if they were started).

For this class to work properly, we need to disable the transactions of the `DatabaseCleaner`.
Otherwise the rails server process does not have access to the data created in the test.
We can do this easily by tagging a `context` or a `describe` block with `:http_interaction`.
This also enables Ontohub and Hets to communicate by temporarily overriding the hostname.
