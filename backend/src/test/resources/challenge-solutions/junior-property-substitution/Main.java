import java.util.Map;

public class Main {
    public static String substitute(String template, Map<String, String> properties) {
        if (template == null || properties == null) {
            throw new IllegalArgumentException("template and properties are required");
        }
        StringBuilder result = new StringBuilder();
        int index = 0;
        while (index < template.length()) {
            int start = template.indexOf("${", index);
            if (start < 0) {
                result.append(template, index, template.length());
                break;
            }
            result.append(template, index, start);
            int end = template.indexOf('}', start + 2);
            if (end < 0) {
                result.append(template, start, template.length());
                break;
            }
            String name = template.substring(start + 2, end);
            String value = name.isEmpty() ? null : properties.get(name);
            if (value == null) {
                result.append(template, start, end + 1);
            } else {
                result.append(value);
            }
            index = end + 1;
        }
        return result.toString();
    }
}
