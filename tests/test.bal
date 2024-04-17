import ballerina/test;
import ballerina/io;

const OUTPUT_PATH = "target/tests/output.md";

@test:Config
function testBalNotebookToMdConversion() returns error? {
    check convertToMd("tests/resources/valid_notebook.balnotebook", OUTPUT_PATH);
    string[] expected = check io:fileReadLines("tests/resources/valid_notebook.md");
    string[] actual = check io:fileReadLines(OUTPUT_PATH);
    test:assertEquals(actual, expected);
}
