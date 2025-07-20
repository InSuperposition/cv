import { Input, Button, Form } from "@atomic-identity/form";

export default function Education() {
  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    console.log("Form submitted");
  };

  return (
    <>
      <h1>Contact</h1>
      <Form name="education" onSubmit={handleSubmit}>
        <Input name="institution" placeholder="Institution name" />
        <Input name="degree" placeholder="Degree" />
        <Button name="submit" type="submit">
          Send
        </Button>
      </Form>
    </>
  );
}
