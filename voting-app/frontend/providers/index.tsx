import ThemeProvider from "@/providers/theme-provider";
import QueryClientContext from "./query-client-context";
import SuiClientContext from "./sui-client-context";

export default async function RootContext({ children }: React.PropsWithChildren) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
      <QueryClientContext>
        <SuiClientContext>{children}</SuiClientContext>
      </QueryClientContext>
    </ThemeProvider>
  );
}
