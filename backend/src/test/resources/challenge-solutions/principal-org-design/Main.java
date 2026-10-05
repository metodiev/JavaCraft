import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> review(boolean clearOwnership, int servicesPerTeam, boolean platformTeamExists) {
        List<String> out = new ArrayList<>();
        if (!clearOwnership) {
            out.add("ownership is unclear: assign one accountable team per service");
        }
        if (servicesPerTeam < 1) {
            out.add(servicesPerTeam + " services per team is invalid: a team must own at least one service");
        } else if (servicesPerTeam > 10) {
            out.add(servicesPerTeam + " services per team is too many: split the team or merge the services");
        }
        if (!platformTeamExists) {
            out.add("no platform team: create one to own shared build, deploy and observability tooling");
        }
        if (out.isEmpty()) {
            out.add("topology is healthy: ownership is clear and services are sized well");
        }
        return out;
    }
}
