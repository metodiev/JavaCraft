public class Main {
    public static String relationship(boolean upstreamControlsModel, boolean downstreamAdoptsUpstream,
            boolean translationLayer) {
        if (translationLayer && !downstreamAdoptsUpstream) {
            return "ANTICORRUPTION_LAYER";
        }
        if (upstreamControlsModel && downstreamAdoptsUpstream && !translationLayer) {
            return "CONFORMIST";
        }
        if (!upstreamControlsModel && !downstreamAdoptsUpstream && !translationLayer) {
            return "SHARED_KERNEL";
        }
        return "CUSTOMER_SUPPLIER";
    }
}
