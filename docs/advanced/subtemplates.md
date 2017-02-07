You can include other templates in your templates by using the built-in `Tiller::render` [helper module](#helper-modules). For example, if you have a template called `main.erb`, you can include another template called `sub.erb` by calling this module inside `main.erb`:

```erb
This is the main.erb template. 
This will include the sub.erb template below this line:
<%= Tiller::render('sub.erb') -%>
```

You can nest sub-templates as deeply as you wish, so you can have sub-templates including another sub-template and so on. However, it is important to note that all variables for sub-templates are evaluated only at the level of the top-level template. 

Therefore, trying to pass a variable to the sub-template by putting something like this in your `common.yaml` will not work:

```
sub.erb:
  config:
    sub_var: This is a var for the sub-template
```

You will not be able to access `sub_var` from your template - you will need to declare it in the `main.erb` block instead, where it will be available to all sub-templates.
