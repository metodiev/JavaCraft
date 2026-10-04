public class Main {
    public static boolean mayAdmit(int tenantInUse, int tenantLimit, int globalInUse, int globalLimit, int requested) {
        if (tenantInUse < 0 || tenantLimit < 0 || globalInUse < 0 || globalLimit < 0 || requested < 1) {
            throw new IllegalArgumentException("invalid quota arguments");
        }
        return (long) tenantInUse + requested <= tenantLimit && (long) globalInUse + requested <= globalLimit;
    }
}
