public class SwitchOp {
    public static void main(String[] args) {
        int x = (args.length > 0) ? Integer.parseInt(args[0]) : 2;
        int y = (args.length > 1) ? Integer.parseInt(args[1]) : 1000;

        denseSwitch(x);
        sparseSwitch(y);
    }

    static void denseSwitch(int v) {
        switch (v) {
            case 1:
                System.out.println("one");
                break;
            case 2:
                System.out.println("two");
                break;
            case 3:
                System.out.println("three");
                break;
            case 4:
                System.out.println("four");
                break;
            default:
                System.out.println("dense-default");
        }
    }

    static void sparseSwitch(int v) {
        switch (v) {
            case 10:
                System.out.println("ten");
                break;
            case 1000:
                System.out.println("thousand");
                break;
            case 100000:
                System.out.println("many");
                break;
            default:
                System.out.println("sparse-default");
        }
    }
}
