# XML File plugin
This plugin parses the contents of an XML file (for example, a Maven POM) and makes the resulting structure available to your templates. First, run `gem install crack` to make sure you have the [crack gem](https://github.com/jnunemaker/crack) installed for XML parsing.

You can then enable this plugin by adding `xml_file` to your list of datasources in `common.yaml`. Once this has been done, you can specify two further parameters; either at the top-level of `common.yaml`, or per-template. These parameters are :

* `xml_file_path` : Path to the XML file
* `xml_file_var` : Variable name that your templates will use to access the structure.

For example, assuming the following XML is loaded from a file specified in `xml_file_path` :

```xml
<project>
        <modelVersion>4.0.0</modelVersion>
        <groupId>com.mycompany.app</groupId>
        <artifactId>my-app</artifactId>
        <version>1</version>
</project>
```

If you set `xml_file_var: maven_pom`, you would then be able to reference elements in your templates like so :

```erb
ArtifactID: <%= maven_pom['project']['artifactId'] %>
```

See the [test fixtures](https://github.com/markround/tiller/tree/master/features/fixtures/xml_file) and corresponding [test scenario](https://github.com/markround/tiller/blob/master/features/xml_file.feature) under the features/ directory for full examples.
