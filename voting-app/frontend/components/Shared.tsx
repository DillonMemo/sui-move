import { cn } from "@/lib/utils";

type TextProps = {
  text: string;
  isError?: boolean;
  centered?: boolean;
};

export default function EcText({ text, isError, centered }: TextProps) {
  const classes = cn(isError ? "text-red-500" : "text-gray-500", centered && "text-center");
  return <div className={classes}>{text}</div>;
}
